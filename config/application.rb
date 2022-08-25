require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"
require "sprockets/railtie"
require "active_support/railtie"
require "active_support/dependencies"
require "flipper"
require 'flipper/adapters/pstore'

Bundler.require(*Rails.groups)


# if there is a yml file locally, load all keyword value pairs in the environment
ENV.update YAML.load_file('config/application.yml')[Rails.env] rescue {}

module EchoOpensearch
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # A workaround for https://issues.jboss.org/browse/TORQUE-955
    #config.middleware.use(TorqueboxBackslashFixMiddleware)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    config.autoload_paths += Dir["#{Rails.root}/app/services/**/"]
    config.logger = Logger.new(File.dirname(__FILE__) + "/../log/#{Rails.env}.log")
    config.logger.formatter = Logger::Formatter.new

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Compress JavaScripts and CSS
    config.assets.compress = true
    config.assets.precompile = ['*.js', '*.css', '*.css.erb', '*.png', '*.jpg', '*.jpeg', '*.gif']
    config.assets.prefix = '/assets'
    config.assets.initialize_on_precompile = false

    def self.load_version
      version_file = "#{config.root}/version.txt"
      if File.exist?(version_file)
        return IO.read(version_file)
      elsif File.exist?('.git/config') && `which git`.size > 0
        version = `git rev-parse --abbrev-ref HEAD`
        return version
      end
      '(unknown)'
    end

    config.version = load_version

    config.cwic_tag = 'org.ceos.wgiss.cwic.*'
    config.cwic_descriptive_keyword = 'CWIC > CEOS WGISS Integrated Catalog'

    config.granule_osdd_tag = 'opensearch.granule.osdd'
    config.granule_osdd_descriptive_keyword = 'The association of this tag with a collection means that clients will use the collection provider granule search OpenSearch API rather than CMR'

    config.geoss_data_core_tag = 'org.geoss.geoss_data-core'
    config.geoss_data_core_descriptive_keyword = 'This is a GEOSS Data-CORE collection with full and open unrestricted access at no more than the cost of reproduction and distribution'

    config.eosdis_tag = 'gov.nasa.eosdis'
    config.eosdis_descriptive_keyword = 'NASA Earth Science Data and Information System'

    config.fedeo_tag = 'int.esa.fedeo'
    config.fedeo_descriptive_keyword = 'Federated Earth Observation missions access'

    config.eosdis_providers = %w[
        NSIDCV0
        ORNL_DAAC
        LARC_ASDC
        LARC
        LAADS
        USGS_LTA
        USGS
        GES_DISC
        USGS_EROS
        GHRC
        SEDAC
        ASF
        LPDAAC_ECS
        LANCEMODIS
        NSIDC_ECS
        OB_DAAC
        CDDIS
        LM_FIRMS
        LANCEAMSR2
        OMINRT
        PODAAC
        OBPG
  ]

  config.ceos_agencies = [
      '{
          "name": "CNES",
          "data_centers": ["FR/CNES*"]
      }',
      '{
        "name": "CREDAS",
        "data_centers": ["AR/CREDAS"]
      }',
      '{
        "name": "CSIRO",
        "data_centers": ["AU/CSIRO/*"]
      }',
      '{
        "name": "DLR",
        "data_centers": ["DE/DLR/*"]
      }',
      '{
        "name": "EUMETSAT",
        "data_centers": ["EUMETSAT", "EUMETSAT/OSISAF"]
      }',
      '{
        "name": "ESA",
        "data_centers": ["ESA/*"]
      }',
      '{
        "name": "GISTDA",
        "data_centers": ["TH/MSTE/GISTDA"]
      }',
      '{
          "name": "ISRO",
          "data_centers": ["IN/ISRO/*"]
      }',
      '{
          "name": "INPE",
          "data_centers": ["BR/INPE/*"]
      }',
      '{
          "name": "KARI",
          "data_centers": ["KR/KARI"]
      }',
      '{
          "name": "JAXA",
          "data_centers": ["JP/JAXA/*"]
      }',
      '{
          "name": "NOAA",
          "data_centers": ["DOC/NOAA/*"]
      }',
      '{
          "name": "NRSCC",
          "data_centers": ["CN/MST/NRSCC"]
      }',
      '{
          "name": "NSMC/CMA",
          "data_centers": ["CN/FENGYUN"]
      }',
      '{
          "name": "NASC",
          "data_centers": ["UA/NASC"]
      }',
      '{
          "name": "ROSHYDROMET",
          "data_centers": ["RU/ROSHYDROMET/FERHRI"]
      }',
      '{
          "name": "ROSKOSMOS",
          "data_centers": ["RU/NTs OMZ"]
      }',
      '{
          "name": "SANSA",
          "data_centers": ["ZA/SANSA/HERMANUS"]
      }',
      '{
          "name": "USGS",
          "data_centers": ["DOI/USGS/*"]
      }',
      '{
          "name": "NASA",
          "data_centers": ["NASA/*", "ASF", "LP_DAAC", "MSFC", "ORNL_DAAC"]
      }'
  ]

  config.cwic_granules_osdd_endpoint = "https://cwic.wgiss.ceos.org/"

  config.holdings_providers = [
    { 'provider' => 'FEDEO',   'params' => { 'providers'   => %w[FEDEO ESA] } },
    { 'provider' => 'ISRO',    'params' => { 'dataCenters' => %w[IN/ISRO/NRSC-BHUVAN IN/ISRO/NDC IN/ISRO/MOSDAC] } },
    { 'provider' => 'NRSCC',   'params' => { 'provider'    => 'NRSCC' } },
    { 'provider' => 'USGSLSI', 'params' => { 'provider'    => 'USGS_LTA' } }
  ]

  Flipper.configure do |config|
    config.default do
      # pick an adapter, this uses memory, any will do
      adapter = Flipper::Adapters::PStore.new
      # pass adapter to handy DSL instance
      Flipper.new(adapter)
    end
  end

  if ENV["USE_CWIC_SERVER"] == "true"
    Flipper.enable(:use_cwic_server)
  else
    Flipper.disable(:use_cwic_server)
  end

    ## additional default configuration parameters used to run tests or a basic local run with no scheduled tagging
    ## capabilities
    def self.update_env(name, value)
      if (ENV[name] == nil)
        ENV.update({name => value})
      end
    end
    update_env('opensearch_url', 'http://localhost:3000/opensearch')
    update_env('catalog_rest_endpoint', 'https://cmr.earthdata.nasa.gov/search/')
    update_env('echo_rest_endpoint','https://cmr.earthdata.nasa.gov/legacy-services/rest/')
    update_env('contact','echodev@echo.nasa.gov')
    update_env('public_catalog_rest_endpoint','https://cmr.earthdata.nasa.gov/search/')
    update_env('release_page', 'https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information')
    update_env('documentation_page','https://wiki.earthdata.nasa.gov/display/CMR/Common+Metadata+Repository+Home')
    update_env('organization_contact_name','Stephen Berrick')

  end
end
