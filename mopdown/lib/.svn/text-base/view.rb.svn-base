require 'model'
require 'service'

module View

  class PagingViewer
    attr_reader :page_num
    
    def initialize page_list
      @page_num=1
      @page_list=page_list
    end
    
    def get_page
      @page_list[@page_num-1]
    end
    
    def jump_to_page page_num
          @page_num=page_num
          get_page
    end
        
    def has_next?
      @page_num<page_count
    end

    def has_prev?
      @page_num>1
    end
    
    def first_page
      @page_num=1
      get_page
    end
    
    def next_page
      @page_num=@page_num+1
      get_page
    end
    
    def prev_page
      @page_num=@page_num-1
      get_page
    end
    
    def page_count
      @page_list.size
    end
    
    def page_status
      @page_num.to_s+"/"+page_count.to_s
    end
    
  end
  
  class LetterCatViewer<PagingViewer
    def initialize subcat
      @subcat=subcat
      super(subcat.page_list)
    end
    
    def letter
      @subcat.letter
    end
  end

  class VolViewer<PagingViewer
    attr_reader :page_num
    
    def initialize vol
      service=Service::FileDataService.instance
      page_list=service.load_vol_pages(vol)
      super(page_list)
    end
  end
end