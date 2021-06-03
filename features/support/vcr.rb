VCR.configure do |c|
  # By default VCR will intercept all http calls. We don't want it to intercept echo-access calls, just catalog-rest and echo-rest.
  #c.ignore_hosts '127.0.0.1', 'localhost'
  # The directory where your cassettes will be saved
  c.cassette_library_dir = 'features/fixtures'
  c.hook_into :webmock

  c.ignore_hosts '127.0.0.1', 'localhost'
  c.default_cassette_options = {:record => :once, :decode_compressed_response => true}
  #c.default_cassette_options = {:record => :new_episodes, :decode_compressed_response => true}
end

VCR.cucumber_tags do |t|
  t.tags '@datasets_search_atom', '@datasets_search_by_placename_atom', '@datasets_search_by_uid_atom', '@datasets_search_by_wkt_atom', '@datasets_search_dc_temporal_atom', '@datasets_search_traversal_atom', '@datasets_search_validation_atom'
  t.tags '@datasets_search_html', '@datasets_search_by_placename_html', '@datasets_search_by_uid_html', '@datasets_search_traversal_html', '@datasets_search_validation_html'

  t.tags '@granules_search_atom', '@granules_search_by_dataset_id_atom', '@granules_search_by_placename_atom', '@granules_search_by_uid_atom', '@granules_search_by_wkt_atom', '@granules_search_dc_temporal_atom', '@granules_search_traversal_atom', '@granules_search_validation_atom'
  t.tags '@granules_search_html', '@granules_search_by_placename_html', '@granules_search_by_uid_html', '@granules_search_validation_html'

  t.tags '@datasets_osdd', '@granules_osdd'

  t.tags '@datasets_search_cwic_atom'

  t.tags '@datasets_search_collection_specific_granule_osdd'

  t.tags '@datasets_search_by_granules_only_atom', '@datasets_search_by_granules_only_html'

  t.tags '@datasets_search_by_cwic_only_atom', '@datasets_search_by_cwic_only_html'

  t.tags '@datasets_search_by_geoss_only_atom', '@datasets_search_by_geoss_only_html', '@datasets_search_geoss_atom'
end
