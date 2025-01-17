module Sitemapper
  class Streamer < Builder

    def initialize(@host : String, @max_urls : Int32, @use_index : Bool, @storage : Sitemapper::Storage.class, @storage_path : String)
      @paginator = Paginator.new(limit: @max_urls)
      @filenames = [] of String
      @sitemaps = [] of Hash(String, String)
      @current_page = 1
    end

    def add(path, **kwargs) : self
      options = SitemapOptions.new(**kwargs)
      paginator.add(path, options)
      if paginator.paths.size.modulo(@max_urls).zero?
        flush
      end
      self
    end

    def flush
      page = @current_page
      filename = filename_for_current_page
      doc = build_xml_for_page(paginator.items(1))

      @sitemaps << {"name" => filename, "data" => doc}
      @filenames << filename

      storage = @storage.new(@sitemaps)
      storage.save(@storage_path)

      @current_page += 1
      @sitemaps = [] of Hash(String, String)
      @paginator = Paginator.new(limit: @max_urls)
    end

    private def filename_for_current_page
      "sitemap#{@current_page}.xml"
    end

  end
end
