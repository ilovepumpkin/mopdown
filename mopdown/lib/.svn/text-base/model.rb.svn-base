module Model
  class SearchIndex
    attr_accessor :sii_list
    def initialize
      @sii_list=Array.new
    end
    
    def size
      @sii_list.size
    end
    
    def add_item si_item
      @sii_list<<si_item
    end
    
    def match_name key
      m_list=Array.new
      @sii_list.each{|sii|        
        if sii.book_name.match(/(.*)#{key}(.*)/)!=nil
           m_list<<sii
        end  
      }
      return m_list
    end
    
    def get_sii book_name
      @sii_list.each{|sii|        
        if sii.book_name==book_name
           return sii
        end  
      }
    end
    
  end
  
  class SIItem
    attr_accessor :book_name,:pagefile_path,:letter
  end

  class Catalog
    attr_accessor:subcat_list
  end    
  
  class SubCat
    attr_accessor:letter,:page_list
    def initialize
      @page_list=Array.new
    end
    def add_page page
      page.letter=self.letter
      @page_list<<page
    end
    def total_page_num
      @page_list.length
    end
    
    def get_page page_num
        @page_list.each{|p|
           if p.page_num.to_s==(page_num-1).to_s
             return p
           end
        }
        return nil
    end
  end
  
  class SubCatPage
    attr_accessor:page_num,:thumb_list,:letter
    def get_thumb_by_name name
        @thumb_list.each{|t|
            if t.book_name==name
               return t
            end  
        }
    end
  end
  
  class Thumb        
      attr_accessor :book_name,:book_index_url,:img_url,:author,:abstract,:vols,:letter
  end
    
  class Volumn
      attr_accessor :vol_name,:vol_url,:page_count,:book_name
  end
    
  class VolPage
    attr_accessor :img_path
  end
    
end