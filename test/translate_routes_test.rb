plugin_root = File.join(File.dirname(__FILE__), '..')
app_root = plugin_root + '/../../..'

require 'test/unit'

ENV['RAILS_ENV'] = 'test'
require File.expand_path(app_root + '/config/boot')
require 'action_controller'
require 'action_controller/test_process'
require 'active_support'

require "#{plugin_root}/lib/translate_routes"
RAILS_ROOT = plugin_root

class PeopleController < ActionController::Base;  end

class TranslateRoutesTest < Test::Unit::TestCase

  def setup
    @controller = ActionController::Base.new
    @view = ActionView::Base.new
  end

  # Unnamed routes, prefix

  def test_unnamed_empty_route_with_prefix
    ActionController::Routing::Routes.draw { |map| map.connect '', :controller => 'people', :action => 'index' }
    config_default_locale_settings('en-US', true)
    ActionController::Routing::Translator.translate { |t| t['en-US'] = {}; t['es-ES'] = {'people' => 'gente'} }
  
    assert_routing '/es-ES', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_routing '/en-US', :controller => 'people', :action => 'index', :locale => 'en-US'
  end
  
  def test_unnamed_untranslated_route_with_prefix
    ActionController::Routing::Routes.draw { |map| map.connect 'foo', :controller => 'people', :action => 'index' }
    config_default_locale_settings('en-US', true)
    ActionController::Routing::Translator.translate { |t| t['en-US'] = {}; t['es-ES'] = {'people' => 'gente'} }
  
    assert_routing '/es-ES/foo', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_routing '/en-US/foo', :controller => 'people', :action => 'index', :locale => 'en-US'
  end
  
  def test_unnamed_translated_route_on_default_locale_with_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('es-ES', true)
    ActionController::Routing::Translator.translate { |t| t['en-US'] = {}; t['es-ES'] = {'people' => 'gente'} }
  
    assert_routing '/es-ES/gente', :controller => 'people', :action => 'index', :locale => 'es-ES'    
  end

  def test_unnamed_translated_route_on_non_default_locale_with_prefix
    ActionController::Routing::Routes.draw { |map| map.connect 'people', :controller => 'people', :action => 'index' }
    config_default_locale_settings('en-US', true)
    ActionController::Routing::Translator.translate { |t| t['en-US'] = {}; t['es-ES'] = {'people' => 'gente'} }
  
    assert_routing '/es-ES/gente', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_routing '/en-US/people', :controller => 'people', :action => 'index', :locale => 'en-US'    
  end


  # Unnamed routes, non-prefix

  def test_unnamed_empty_route_without_prefix
    ActionController::Routing::Routes.draw { |map| map.connect '', :controller => 'people', :action => 'index' }
    config_default_locale_settings('en-US', false)
    ActionController::Routing::Translator.translate { |t| t['en-US'] = {}; t['es-ES'] = {'people' => 'gente'} }
  
    assert_routing '/es-ES', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'en-US'
  end
  
  def test_unnamed_untranslated_route_without_prefix
    ActionController::Routing::Routes.draw { |map| map.connect 'foo', :controller => 'people', :action => 'index'}
    config_default_locale_settings('en-US', false)
    ActionController::Routing::Translator.translate { |t| t['en-US'] = {}; t['es-ES'] = {'people' => 'gente'} }
    
    assert_routing '/es-ES/foo', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_routing '/foo', :controller => 'people', :action => 'index', :locale => 'en-US'
  end
  
  def test_unnamed_translated_route_on_default_locale_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('es-ES', false)
    ActionController::Routing::Translator.translate { |t| t['en-US'] = {}; t['es-ES'] = {'people' => 'gente'} }

    assert_routing '/en-US/people', :controller => 'people', :action => 'index', :locale => 'en-US'
    assert_routing 'gente', :controller => 'people', :action => 'index', :locale => 'es-ES'
  end

  def test_unnamed_translated_route_on_non_default_locale_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('en-US', false)
    ActionController::Routing::Translator.translate { |t| t['en-US'] = {}; t['es-ES'] = {'people' => 'gente'} }

    assert_routing '/es-ES/gente', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en-US'
  end

  # Named routes, prefix

  def test_named_empty_route_with_prefix
    ActionController::Routing::Routes.draw { |map| map.people '', :controller => 'people', :action => 'index' }
    config_default_locale_settings('en-US', true)
    ActionController::Routing::Translator.translate { |t| t['en-US'] = {}; t['es-ES'] = {'people' => 'gente'} }

    assert_routing '/es-ES', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_routing '/en-US', :controller => 'people', :action => 'index', :locale => 'en-US'
    assert_helpers_include :people_en_us, :people_es_es, :people
  end
  
  def test_named_untranslated_route_with_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'foo', :controller => 'people', :action => 'index'}
    config_default_locale_settings('en-US', true)
    ActionController::Routing::Translator.translate { |t| t['en-US'] = {}; t['es-ES'] = {'people' => 'gente'} }
  
    assert_routing '/es-ES/foo', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_routing '/en-US/foo', :controller => 'people', :action => 'index', :locale => 'en-US'
    assert_helpers_include :people_en_us, :people_es_es, :people
  end
  
  def test_named_translated_route_on_default_locale_with_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('es-ES', true)
    ActionController::Routing::Translator.translate { |t| t['en-US'] = {}; t['es-ES'] = {'people' => 'gente'} }

    assert_routing '/en-US/people', :controller => 'people', :action => 'index', :locale => 'en-US'
    assert_routing '/es-ES/gente', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_helpers_include :people_en_us, :people_es_es, :people
  end

  def test_named_translated_route_on_non_default_locale_with_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index' }
    config_default_locale_settings('en-US', true)
    ActionController::Routing::Translator.translate { |t| t['en-US'] = {}; t['es-ES'] = {'people' => 'gente'} }
  
    assert_routing '/es-ES/gente', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_routing '/en-US/people', :controller => 'people', :action => 'index', :locale => 'en-US'
    assert_helpers_include :people_en_us, :people_es_es, :people
  end
  
  # Named routes, non-prefix

  def test_named_empty_route_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people '', :controller => 'people', :action => 'index'}
    config_default_locale_settings('es-ES', false)
    ActionController::Routing::Translator.translate { |t|  t['es-ES'] = {};  t['en-US'] = {'people' => 'gente'}; }

    assert_routing '/en-US', :controller => 'people', :action => 'index', :locale => 'en-US'
    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_routing '', :controller => 'people', :action => 'index', :locale => 'es-ES'
  end
  
  def test_named_untranslated_route_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'foo', :controller => 'people', :action => 'index'}
    config_default_locale_settings('es-ES', false)
    ActionController::Routing::Translator.translate { |t| t['en-US'] = {}; t['es-ES'] = {'people' => 'gente'} }

    assert_routing '/en-US/foo', :controller => 'people', :action => 'index', :locale => 'en-US'
    assert_routing 'foo', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_helpers_include :people_en_us, :people_es_es, :people
  end
  
  def test_named_translated_route_on_default_locale_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('es-ES', false)
    ActionController::Routing::Translator.translate { |t| t['en-US'] = {}; t['es-ES'] = {'people' => 'gente'} }
  
    assert_routing '/en-US/people', :controller => 'people', :action => 'index', :locale => 'en-US'
    assert_routing 'gente', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_helpers_include :people_en_us, :people_es_es, :people
  end

  def test_named_translated_route_on_non_default_locale_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('en-US', false)
    ActionController::Routing::Translator.translate { |t| t['en-US'] = {}; t['es-ES'] = {'people' => 'gente'} }
  
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en-US'
    assert_routing '/es-ES/gente', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_helpers_include :people_en_us, :people_es_es, :people
  end

  def test_languages_load_from_file
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('en-US', false)
    ActionController::Routing::Translator.translate_from_file 'test', 'locales', 'routes.yml'
    
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en-US'
    assert_routing '/es-ES/gente', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_helpers_include :people_en_us, :people_es_es, :people
  end
  
  def test_languages_load_from_file_without_dictionary_for_default_locale
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('fr-FR', false)
    ActionController::Routing::Translator.translate_from_file 'test', 'locales', 'routes.yml'
    
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'fr-FR'
    assert_routing '/en-US/people', :controller => 'people', :action => 'index', :locale => 'en-US'
    assert_routing '/es-ES/gente', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_helpers_include :people_fr_fr, :people_en_us, :people_es_es, :people
  end

  def test_i18n_based_translations_setting_locales
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('en-US', false)
    I18n.backend = StubbedI18nBackend
    ActionController::Routing::Translator.i18n('es-ES')

    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en-US'    
    assert_routing '/es-ES/gente', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_helpers_include :people_en_us, :people_es_es, :people
  end

  def test_i18n_based_translations_taking_i18n_available_locales
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('en-US', false)
    I18n.stubs(:available_locales).at_least_once.returns StubbedI18nBackend.available_locales
    I18n.backend = StubbedI18nBackend
    ActionController::Routing::Translator.i18n

    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en-US'
    assert_routing '/fr-FR/people', :controller => 'people', :action => 'index', :locale => 'fr-FR'
    assert_routing '/es-ES/gente', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_helpers_include :people_fr_fr, :people_en_us, :people_es_es, :people
  end

  # Root ("empty") route
  def test_root_route_without_prefix
    ActionController::Routing::Routes.draw { |map| map.root :controller => 'people', :action => 'index'}
    config_default_locale_settings('es-ES', false)
    ActionController::Routing::Translator.translate_from_file 'test', 'locales', 'routes.yml'

    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_routing '/en-US', :controller => 'people', :action => 'index', :locale => 'en-US'

    # test that the given route is not recognized
    assert_raise ActionController::RoutingError do
      assert_routing '/es-ES', :controller => 'people', :action => 'index', :locale => 'es-ES'
    end
  end

  def test_root_route_with_prefix
    ActionController::Routing::Routes.draw { |map| map.root :controller => 'people', :action => 'index'}
    config_default_locale_settings('es-ES', true)
    ActionController::Routing::Translator.translate_from_file 'test', 'locales', 'routes.yml'

    assert_routing '/', :controller => 'people', :action => 'index'
    assert_routing '/es-ES', :controller => 'people', :action => 'index', :locale => 'es-ES'
    assert_routing '/en-US', :controller => 'people', :action => 'index', :locale => 'en-US'
  end

  # Configuration options

  def test_action_controller_gets_locale_setter
    ActionController::Base.instance_methods.include?('set_locale_from_url')
  end

  def test_action_controller_gets_locale_suffix_helper
    ActionController::Base.instance_methods.include?('locale_suffix')
  end

  def test_action_view_gets_locale_suffix_helper
    ActionView::Base.instance_methods.include?('locale_suffix')
  end

  private
  
  def assert_helpers_include(*helpers)
    helpers.each do |helper|
      ['_url', '_path'].each do |suffix|    
        [@controller, @view].each { |obj| assert_respond_to obj, "#{helper}#{suffix}".to_sym }
      end
    end
    
  end

  def config_default_locale_settings(locale, with_prefix)
    I18n.default_locale = locale
    ActionController::Routing::Translator.prefix_on_default_locale = with_prefix
  end

  class StubbedI18nBackend
    
    
    @@translations = { 
      'es-ES' => { 'people' => 'gente'}, 
      'fr-FR' => {} # empty on purpose to test behaviour on incompleteness scenarios
    }
    
    def self.translate(locale, key, options)
      @@translations[locale][key] || options[:default]
    rescue 
      options[:default]
    end

    def self.available_locales
      @@translations.keys
    end
    
  end
  
end
