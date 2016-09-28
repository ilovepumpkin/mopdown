require 'persister'
require 'web'
require 'util'
require 'singleton'
require 'thread'

module Service
  class FileDataService
    include Singleton
    
    def initialize
        @persister=Persister::FilePersister.new
        @web=Web::WebRetriever.new
      end
      
    def get_thumb book_name
        sii=Util::SearchUtil.instance.get_search_index.get_sii(book_name)
        page_path=sii.pagefile_path
        page=@persister.load_page_bypath(page_path)
        thumb=page.get_thumb_by_name(book_name)
        thumb.letter=sii.letter
        return thumb
      end
      
    def in_lib? book
      @persister.in_lib?(book)
    end
      
    def delete_book book
      @persister.delete_book(book)
    end      
      
    def bookmark book
      @persister.bookmark(book)
    end
     
    def vol_exist? vol
      @persister.vol_exist?(vol)
    end      
      
    def delete_vol vol
      @persister.delete_vol(vol)
    end      
      
    def get_mybooks
      @persister.get_mybooks
    end
      
    def load_vol_pages vol
      @persister.load_vol_pages(vol)
    end
    
    def si_exists?
      @persister.si_exists?
    end
    
    def build_search_index
      @persister.build_search_index
    end
    
    def load_search_index
      @persister.load_search_index
    end
    
    #~ def down_catalog range,inc_cover
      #~ range=('a'..'z') if range==nil
      #~ resume_letter=@persister.get_resume_letter
      #~ range.each{|letter|
        #~ if letter<resume_letter
          #~ puts "��ĸ"+letter+"Ŀ¼֮ǰ�ѳɹ�����������"
        #~ else
          #~ puts "����������ĸ"+letter+"Ŀ¼..."
          #~ @persister.mk_letter_dir(letter)
          #~ subcat=@web.get_subcat_by_letter(letter)
          #~ puts "������Ϣ�Ѵӻ�������ȡ�����ڹ�������Ŀ¼��Ϣ..."
          #~ @persister.save_subcat(subcat,inc_cover)
          #~ puts "��ĸ"+letter+"Ŀ¼�ѳɹ�������ɣ�"
        #~ end
      #~ }
      
      #~ build_search_index
      #~ puts "�����������������ɹ�!"
    #~ end
    
    def build_local_catalog range,msg_pipe
      helper=Util::CatalogDownHelper.new(range,msg_pipe)
      helper.start(3,false)     
      puts "���ڹ���������������..."
      build_search_index
      puts "�����������������ɹ�!"
      puts "����Ŀ¼��Ϣ�������!"
    end
    
    def load_page letter,page_num
      @persister.load_page(letter,page_num)
    end
    
    def load_subcat letter
      @persister.load_subcat(letter)  
    end
        
    def letter_exists? letter
      @persister.letter_exists?(letter)
    end
    
    def down_cover letter,book
      @persister.down_cover(letter,book)
    end  
    
    def get_finished_page_count book_name,vol
      @persister.get_finished_page_count(book_name,vol)
    end
  end
end