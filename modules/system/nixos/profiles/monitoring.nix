{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  cfg = config.profiles.monitoring;
  exportersCfg = config.services.prometheus.exporters;
in
{
  options.profiles.monitoring = {
    enable = lib.mkEnableOption "system monitoring profile";
    extraScrapeTargets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        extra prometheus scrape targets
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      config.services.grafana.settings.server.http_port
      config.services.grafana-image-renderer.settings.service.port
    ];
    services.grafana = {
      enable = true;
      settings = {
        server.http_addr = "0.0.0.0"; # FIXME: nginx will rev proxy this
        auth.disable_login_form = true;
        "auth.anonymous" = {
          enabled = true;
          org_role = "Editor";
        };
      };
      declarativePlugins = with unstable.grafanaPlugins; [
        grafana-clickhouse-datasource
      ];
      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "clickhouse";
            type = "grafana-clickhouse-datasource";
            jsonData = {
              host = "localhost";
              port = "9000";
            };
          }
        ];
      };
    };
    services.prometheus.exporters = {
      node = {
        enable = true;
        listenAddress = "127.0.0.1";
      };
      smartctl = {
        enable = true;
        listenAddress = "127.0.0.1";
      };
      zfs = {
        enable = config.boot.zfs.enabled;
        listenAddress = "127.0.0.1";
      };
    };

    services.clickhouse.enable = true;
    systemd.services.opentelemetry-collector.after = [ "clickhouse.service" ];

    services.opentelemetry-collector = {
      enable = true;
      package = unstable.opentelemetry-collector-contrib;
      settings = {
        # SystemD journal logging
        receivers.journald = {
          directory = "/var/log/journal";
          priority = "info";
        };

        # FIXME: Visualizing metrics in Grafana is a bit of a pain with
        # Clickhouse; re-enable this once Victoriametrics is up & running.
        # 
        # Prometheus exporter metrics scraping
        # receivers.prometheus.config.scrape_configs = [
        #   {
        #     job_name = config.networking.hostName;
        #     scrape_interval = "1m";
        #     static_configs = [
        #       {
        #         targets = [
        #           # node
        #           "${exportersCfg.node.listenAddress}:${builtins.toString exportersCfg.node.port}"
        #           # smartctl
        #           "${exportersCfg.smartctl.listenAddress}:${builtins.toString exportersCfg.smartctl.port}"
        #         ] ++ cfg.extraScrapeTargets;
        #       }
        #     ];
        #   }
        # ];

        exporters.clickhouse = {
          endpoint = "tcp://127.0.0.1:9000"; # NOTE: 9000 = default native clickhouse port
          database = "otel";
          compress = "zstd";
          logs_table_name = "logs";
          traces_table_name = "traces";
        };

        service.pipelines = {
          logs = {
            receivers = [ "journald" ];
            processors = [
              "transform/journald"
              "batch"
              "resourcedetection/system"
              "groupbyattrs"
            ];
            exporters = [ "clickhouse" ];
          };
          # FIXME: Setup a pipeline pushing metrics to Victoriametrics
          # metrics = {
          #   receivers = [ "prometheus" ];
          #   processors = [ "batch" ];
          #   exporters = [ "clickhouse" ];
          # };
        };

        processors = {
          batch = {
            timeout = "5s";
            send_batch_size = 100000;
          };
          "resourcedetection/system" = {
            detectors = [ "system" ];
            system.hostname_sources = [ "os" ];
          };
          "transform/journald" = {
            error_mode = "ignore";
            log_statements = [
              {
                context = "log";
                statements = [
                  "set(severity_number, SEVERITY_NUMBER_DEBUG) where Int(body[\"PRIORITY\"]) == 7"
                  "set(severity_number, SEVERITY_NUMBER_INFO) where Int(body[\"PRIORITY\"]) == 6"
                  "set(severity_number, SEVERITY_NUMBER_INFO2) where Int(body[\"PRIORITY\"]) == 5"
                  "set(severity_number, SEVERITY_NUMBER_WARN) where Int(body[\"PRIORITY\"]) == 4"
                  "set(severity_number, SEVERITY_NUMBER_ERROR) where Int(body[\"PRIORITY\"]) == 3"
                  "set(severity_number, SEVERITY_NUMBER_FATAL) where Int(body[\"PRIORITY\"]) <= 2"
                  "set(attributes[\"priority\"], body[\"PRIORITY\"])"
                  "set(attributes[\"process.comm\"], body[\"_COMM\"])"
                  "set(attributes[\"process.exec\"], body[\"_EXE\"])"
                  "set(attributes[\"process.uid\"], body[\"_UID\"])"
                  "set(attributes[\"process.gid\"], body[\"_GID\"])"
                  "set(attributes[\"owner_uid\"], body[\"_SYSTEMD_OWNER_UID\"])"
                  "set(attributes[\"unit\"], body[\"_SYSTEMD_UNIT\"])"
                  "set(attributes[\"syslog_identifier\"], body[\"SYSLOG_IDENTIFIER\"])"
                  "set(attributes[\"syslog_identifier_prefix\"], ConvertCase(body[\"SYSLOG_IDENTIFIER\"], \"lower\")) where body[\"SYSLOG_IDENTIFIER\"] != nil"
                  "replace_pattern(attributes[\"syslog_identifier_prefix\"], \"^[^a-zA-Z]*([a-zA-Z]{3,25}).*\", \"$$1\") where body[\"SYSLOG_IDENTIFIER\"] != nil"
                  "set(attributes[\"unit_prefix\"], ConvertCase(body[\"_SYSTEMD_UNIT\"], \"lower\")) where body[\"_SYSTEMD_UNIT\"] != nil"
                  "replace_pattern(attributes[\"unit_prefix\"], \"^[^a-zA-Z]*([a-zA-Z]{3,25}).*\", \"$$1\") where body[\"_SYSTEMD_UNIT\"] != nil"
                  "set(attributes[\"job\"], attributes[\"syslog_identifier_prefix\"])"
                  "set(attributes[\"job\"], attributes[\"unit_prefix\"]) where attributes[\"job\"] == nil and attributes[\"unit_prefix\"] != nil"
                  "set(body, body[\"MESSAGE\"])"
                ];
              }
            ];
          };
          groupbyattrs = {
            keys = [
              "service.name"
              "host.name"
              "receiver"
              "job"
            ];
          };
        };
      };
    };
  };
}
