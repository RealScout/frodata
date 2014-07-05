module OData
  # Encapsulates the basic details and functionality needed to interact with an
  # OData service.
  class Service
    # The OData Service's URL
    attr_reader :service_url

    # Options to pass around
    attr_reader :options

    # Opens the service based on the requested URL and adds the service to
    # {OData::Registry}
    #
    # @param service_url [String] the URL to the desired OData service
    # @param options [Hash] options to pass to the service
    # @return [OData::Service] an instance of the service
    def initialize(service_url, options = {})
      @service_url = service_url
      @options = default_options.merge(options)
      OData::ServiceRegistry.add(self)
      self
    end

    # Opens the service based on the requested URL and adds the service to
    # {OData::Registry}
    #
    # @param service_url [String] the URL to the desired OData service
    # @param options [Hash] options to pass to the service
    # @return [OData::Service] an instance of the service
    def self.open(service_url, options = {})
      Service.new(service_url, options)
    end

    # Returns a list of entities exposed by the service
    def entity_types
      @entity_types ||= metadata.xpath('//EntityType').collect {|entity| entity.attributes['Name'].value}
    end

    # Returns a hash of EntitySet names keyed to their respective EntityType name
    def entity_sets
      @entity_sets ||= metadata.xpath('//EntityContainer/EntitySet').collect {|entity|
        [
          entity.attributes['EntityType'].value.gsub("#{namespace}.", ''),
          entity.attributes['Name'].value
        ]
      }.to_h
    end

    # Returns a list of ComplexTypes used by the service
    def complex_types
      @complex_types ||= metadata.xpath('//ComplexType').collect {|entity| entity.attributes['Name'].value}
    end

    # Returns the namespace defined on the service's schema
    def namespace
      @namespace ||= metadata.xpath('//Schema').first.attributes['Namespace'].value
    end

    # Returns a more compact inspection of the service object
    def inspect
      "#<#{self.class.name}:#{self.object_id} namespace='#{self.namespace}' service_url='#{self.service_url}'>"
    end

    # Retrieves the EntitySet associated with a specific EntityType by name
    #
    # @param entity_type_name [to_s] the name of the EntityType you want the EntitySet of
    # @return [OData::EntitySet] an OData::EntitySet to query
    def [](entity_set_name)
      xpath_query = "//EntityContainer/EntitySet[@Name='#{entity_set_name}']"
      entity_set_node = metadata.xpath(xpath_query).first
      raise ArgumentError, "Unknown Entity Set: #{entity_set_name}" if entity_set_node.nil?
      container_name = entity_set_node.parent.attributes['Name'].value
      entity_type_name = entity_set_node.attributes['EntityType'].value.gsub(/#{namespace}\./, '')
      OData::EntitySet.new(name: entity_set_name,
                           namespace: namespace,
                           type: entity_type_name.to_s,
                           container: container_name)
    end

    # Execute a request against the service
    #
    # @param url_chunk [to_s] string to append to service url
    # @param additional_options [Hash] options to pass to Typhoeus
    # @return [Typhoeus::Response]
    def execute(url_chunk, additional_options = {})
      request = ::Typhoeus::Request.new(
          "#{service_url}/#{url_chunk}",
          options[:typhoeus].merge({
            method: :get
          }).merge(additional_options)
      )
      request.run
      request.response
    end

    # Find a specific node in the given result set
    #
    # @param results [Typhoeus::Response]
    # @return [Nokogiri::XML::Element]
    def find_node(results, node_name)
      document = ::Nokogiri::XML(results.body)
      document.remove_namespaces!
      document.xpath("//#{node_name}").first
    end

    # Find entity entries in a result set
    #
    # @param results [Typhoeus::Response]
    # @return [Nokogiri::XML::NodeSet]
    def find_entities(results)
      document = ::Nokogiri::XML(results.body)
      document.remove_namespaces!
      document.xpath('//entry')
    end

    # Get the property type for an entity from metadata.
    #
    # @param entity_name [to_s] the name of the relevant entity
    # @param property_name [to_s] the property name needed
    # @return [String] the name of the property's type
    def get_property_type(entity_name, property_name)
      metadata.xpath("//EntityType[@Name='#{entity_name}']/Property[@Name='#{property_name}']").first.attributes['Type'].value
    end

    # Get the property used as the title for an entity from metadata.
    #
    # @param entity_name [to_s] the name of the relevant entity
    # @return [String] the name of the property used as the entity title
    def get_title_property_name(entity_name)
      metadata.xpath("//EntityType[@Name='#{entity_name}']/Property[@FC_TargetPath='SyndicationTitle']").first.attributes['Name'].value
    end

    # Get the property used as the summary for an entity from metadata.
    #
    # @param entity_name [to_s] the name of the relevant entity
    # @return [String] the name of the property used as the entity summary
    def get_summary_property_name(entity_name)
      metadata.xpath("//EntityType[@Name='#{entity_name}']/Property[@FC_TargetPath='SyndicationSummary']").first.attributes['Name'].value
    end

    private

    def default_options
      {
          typhoeus: {}
      }
    end

    def metadata
      @metadata ||= lambda {
        request = ::Typhoeus::Request.new(
            "#{service_url}/$metadata",
            options[:typhoeus].merge({
              method: :get
            })
        )
        request.run
        response = request.response
        ::Nokogiri::XML(response.body).remove_namespaces!
      }.call
    end
  end
end