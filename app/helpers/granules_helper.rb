module GranulesHelper
  def get_provider_from_concept_id(collection_concept_id)
    collection_concept_id.split('-')[1].strip
  end

  def parse_cwic_mapping_by_concept_id(concept_id)
    cwic_mapping_doc_loc = "cwic-mapping.xml"
    if Rails.cache.read("cwic_mapping").nil?
      puts "HERE1"
      cwic_mapping_doc =  File.open(cwic_mapping_doc_loc) { |f| Nokogiri::XML(f) }
      Rails.cache.write("cwic_mapping", cwic_mapping_doc.serialize, expires_in: 24.hours)
    else
      puts "HERE2"
      cwic_mapping_doc = Nokogiri::XML(Rails.cache.read("cwic_mapping"))
    end
    provider = cwic_mapping_doc.xpath("/mappingList/catalog/dataSet[@conceptId=\"#{concept_id}\"]/../@id").text
    mapping_hash = Hash.new
    if provider.present?
      if provider == "NASA"
        mapping_hash['erb_file'] = "descriptor_document.xml.erb"
      else
        mapping_hash['erb_file'] = "#{provider.downcase}.xml.erb"
        mapping_hash['dataset_id'] = cwic_mapping_doc.xpath("/mappingList/catalog/dataSet[@conceptId=\"#{concept_id}\"]/@datasetId").text
        mapping_hash['begin'] = cwic_mapping_doc.xpath("/mappingList/catalog/dataSet[@conceptId=\"#{concept_id}\"]/@begin").text
        mapping_hash['end'] = cwic_mapping_doc.xpath("/mappingList/catalog/dataSet[@conceptId=\"#{concept_id}\"]/@end").text
        mapping_hash['geo_box'] = "#{cwic_mapping_doc.xpath("/mappingList/catalog/dataSet[@conceptId=\"#{concept_id}\"]/@west").text},"\
                                  "#{cwic_mapping_doc.xpath("/mappingList/catalog/dataSet[@conceptId=\"#{concept_id}\"]/@south").text},"\
                                  "#{cwic_mapping_doc.xpath("/mappingList/catalog/dataSet[@conceptId=\"#{concept_id}\"]/@east").text},"\
                                  "#{cwic_mapping_doc.xpath("/mappingList/catalog/dataSet[@conceptId=\"#{concept_id}\"]/@north").text}";
      end
    end
    mapping_hash
  end
end
