require 'yaml'
require 'find'
require 'model'
require 'web'
require 'util'
require 'thread'
require 'fileutils'

include Model

module Persister
  class FilePersister
      def initialize
        @w=Web::WebRetriever.new
        
        @catalog_folder=$root_dir+"/catalog"
        @books_folder=$root_dir+"/books"
        @tmp_folder=$root_dir+"/tmp"
        @tmp_catalog_folder=@tmp_folder+"/catalog"
        
        Dir.mkdir($root_dir) unless File.exist? $root_dir
        Dir.mkdir(@catalog_folder) unless File.exist? @catalog_folder
        Dir.mkdir(@books_folder) unless File.exist? @books_folder
        #~ Dir.mkdir(@tmp_folder) unless File.exist? @tmp_folder
        #~ Dir.mkdir(@tmp_catalog_folder) unless File.exist? @tmp_catalog_folder
      end
      
      def mk_tmp_catalog_dir
        delete_tmp_catalog_dir
        FileUtils.mkdir_p(@tmp_catalog_folder)
      end
      
      def delete_tmp_catalog_dir
        FileUtils.rm_r(@tmp_catalog_folder)
      end
      
      def update_catalog
        FileUtils.rm_r(@catalog_folder)
        FileUtils.cp_r(@tmp_catalog_folder,@catalog_folder)
      end
      
      def mk_letter_dir letter
        letter_dir=File.join(@catalog_folder,letter)
        Dir.mkdir(letter_dir) unless File.exists?(letter_dir)
      end
      
      def get_mybooks
        books=Array.new
        Dir.foreach(@books_folder){|b_dir|
           if !File.file?(b_dir) && !b_dir.match(/^\.(.*)/)
              books<<b_dir
           end
        }
        return books
      end
      
      def delete_book book
        book_path=File.join(@books_folder,book.book_name)
        Util::FileUtil.instance.delete_dir(book_path)
        if !File.exists?(book_path)
           return true
         else
           return false
         end  
       end
       
      def in_lib? book
        book_path=File.join(@books_folder,book.book_name)
        File.exist?(book_path)
      end        
      
      def bookmark book
        book_path=File.join(@books_folder,book.book_name)
        Dir.mkdir(book_path)
      end
      
      def vol_exist? vol
         book_path=File.join(@books_folder,vol.book_name)
         vol_path=File.join(book_path,vol.vol_name)
         return FileTest.exists?(vol_path)
      end
      
      def delete_vol vol
         book_path=File.join(@books_folder,vol.book_name)
         vol_path=File.join(book_path,vol.vol_name)
         Util::FileUtil.instance.delete_dir(vol_path)
         if !File.exists?(vol_path)
           return true
         else
           return false
         end           
      end  
      
      def si_exists?
        si_file=File.join(@catalog_folder,'search_index')
        File.exists?(si_file)
      end
      
      def load_search_index
        si_file=File.join(@catalog_folder,'search_index')
        si=File.open(si_file) { |is|  YAML.load(is) }
        return si
      end
      
      def build_search_index
        si=SearchIndex.new
        
        all=load_all_subcats
        all.each{|subcat|
           subcat.page_list.each{|page|
              letter=page.letter
              page_num=page.page_num
              page.thumb_list.each{|thumb|
                 si_item=SIItem.new
                 si_item.book_name=thumb.book_name
                 si_item.letter=letter
                 si_item.pagefile_path=@catalog_folder+"/"+letter+"/"+letter+"."+page_num
                 si.add_item(si_item)
              }
           }
        }
        
        si_file=File.join(@catalog_folder,'search_index')
        open(si_file,"w"){|os|
              YAML.dump(si,os)
        } 
      end
      
      def load_vol_pages vol
        vol_pages=Array.new
        book_path=File.join(@books_folder,vol.book_name)
        vol_path=File.join(book_path,vol.vol_name)
        Find.find(vol_path) do |f|
               if File.file?(f) && File.extname(f)==".jpg"
                  page=VolPage.new
                  page.img_path=f.to_s
                  vol_pages<<page
               end
             end
        vol_pages.reverse
      end
      
      def get_finished_page_count book_name,vol
        book_path=File.join(@books_folder,book_name)
        vol_path=File.join(book_path,vol.vol_name)
        total_count=0
        Find.find(vol_path) do |f|
               if File.file?(f) && File.extname(f)==".jpg"
                  total_count=total_count+1
               end
             end
        total_count
      end
      
      def down_cover letter,thumb
          img_url=thumb.img_url
          cover_folder=File.join(@catalog_folder,letter,'cover')
          Dir.mkdir(cover_folder) unless File.exist? cover_folder
          @w.down_file(img_url,File.join(cover_folder,img_url.split("/").last))
      end
      
      def letter_exists? letter
        folder=File.join(@catalog_folder,letter.downcase)
        File.exist? folder 
      end
      
      def get_resume_letter
        letter=Dir.entries(@catalog_folder).last
        letter='a' if letter==".."
        letter
      end
      
      def mk_letter_dir letter
        subcat_folder=@catalog_folder+"/"+letter
        Dir.mkdir(subcat_folder) unless File.exist? subcat_folder
      end
      
      def get_catpage_path letter,page_num
        subcat_folder=@catalog_folder+"/"+letter
        path=subcat_folder+"/"+letter.to_s+"."+page_num.to_s
        return path
      end
      
      #~ def save_resume_point(rp)
        #~ file_path=@catalog_folder+"/resume.yaml"
        #~ open(file_path,"w"){|os|
              #~ YAML.dump(rp,os)
        #~ }
      #~ end
      
      #~ def resume_point_exists?
        #~ file_path=@catalog_folder+"/resume.yaml"
        #~ File.exists? file_path
      #~ end
      
      #~ def load_resume_point
        #~ file_path=@catalog_folder+"/resume.yaml"
        #~ rp=File.open(file_path) { |is|  YAML.load(is) }
        #~ return rp
      #~ end
      
      #~ def save_resume_point(rp)
        #~ file_path=@catalog_folder+"/resume.yaml"
        #~ open(file_path,"w"){|os|
              #~ YAML.dump(rp,os)
        #~ }
      #~ end
      
      #~ def delete_resume_point
        #~ file_path=@catalog_folder+"/resume.yaml"
        #~ File.delete(file_path) if File.exists?(file_path)
      #~ end
      
      def save_task_queue(que) 
        que_arr=Array.new
        until que.length<=0
          que_arr<<que.pop
        end
        file_path=@catalog_folder+"/tasks.yaml"
        open(file_path,"w"){|os|
              YAML.dump(que_arr,os)
        } 
      end  
      
      def load_task_queue
        file_path=@catalog_folder+"/tasks.yaml"
        if File.exists?(file_path)
          que_arr=File.open(file_path) { |is|  YAML.load(is) }
          que=Queue.new
          que_arr.each{|task|
             if !File.exists? task["local_file"]
               que.enq(task)
             end
          }
          return que
        else
          return nil
        end
      end
      
      def delete_task_queue
        file_path=@catalog_folder+"/tasks.yaml"
        File.delete(file_path) if File.exists?(file_path)
      end
      
      def task_queue_exists?
        file_path=@catalog_folder+"/tasks.yaml"
        File.exists? file_path
      end  
      
      def save_subcat subcat,inc_cover
        subcat_folder=@catalog_folder+"/"+subcat.letter
        Dir.mkdir(subcat_folder) unless File.exist? subcat_folder
        subcat.page_list.each{|page|
           save_page(page,inc_cover)
        }
      end
      
      def save_page page,inc_cover
        subcat_folder=@tmp_catalog_folder+"/"+page.letter
        Dir.mkdir(subcat_folder) unless File.exist? subcat_folder
        file_path=subcat_folder+"/"+page.letter.to_s+"."+page.page_num.to_s
        if !File.exists?(file_path)
          puts "正在构建文件"+file_path
          open(file_path,"w"){|os|
              YAML.dump(page,os)
          } 
        else
          puts file_path+"已存在，跳过"
        end
        
        if inc_cover==true
            # save cover images
            puts "正在下载封面图片..."
            cover_folder=File.join(subcat_folder,'cover')
            Dir.mkdir(cover_folder) unless File.exist? cover_folder
            page.thumb_list.each{|t|
                 img_url=t.img_url
                 file_path=File.join(cover_folder,img_url.split("/").last)
                 @w.down_file(img_url,file_path)
            }        
          end
          
        end
        
      def load_page_bypath file_path
        page=File.open(file_path) { |is|  YAML.load(is) }
        return page
      end
      
      def load_page letter,page_num
        file_path=@catalog_folder+"/"+letter+"/"+letter+"."+page_num
        page=File.open(file_path) { |is|  YAML.load(is) }
        page.page_num=page_num
        page
      end
      
      def load_all_subcats
        all=Array.new
        ('a'..'z').each{|letter|
           all<<load_subcat(letter)
        }
        return all
      end
      
      def load_subcat letter
        sc=SubCat.new
        sc.letter=letter
        Find.find(@catalog_folder+"/"+letter+"/") do |f|
               Find.prune if f=~/cover/
               if File.file?(f)
                  sc.add_page(load_page(letter,page_num=f.split(".").last))
               end
          end
        sc
      end
      
      def book_path book_name
        book_path=File.join(@books_folder,book_name)        
        return book_path
      end       

      def vol_path vol
        book_path=File.join(@books_folder,vol.book_name)
        vol_path=File.join(book_path,vol.vol_name)
      end
   
      def down_img_page img_page_url,local_img_path
          if !File.exist?(local_img_path)
              resp=@w.get_resp(img_page_url)
              begin
                  real_img_url=@w.get_real_img_url(resp.body)
                  if !@w.down_file(real_img_url,local_img_path)
                    @log.error(local_img_path+" fails to be saved.")        
                  end
              rescue Exception=>e
                @log.error(e)
              end
            end
      end

      def down_vol vol,msg_pipe=nil
        book_name=vol.book_name
        book_path=File.join(@books_folder,book_name)
        Dir.mkdir(book_path) unless File.exists?(book_path)
        
        vol_path=File.join(book_path,vol.vol_name)
        Dir.mkdir(vol_path) unless File.exists?(vol_path)
        
        vol_page_url=vol.vol_url
        
        url_parts=vol_page_url.split("/")
        last_part=url_parts.last
    
        vol.page_count.to_s.to_i.times{|img_num|
            new_last_part=last_part.sub(/.html/,"/"+img_num.to_s+".html")
            url_parts[url_parts.size-1]=new_last_part
            img_page_url=url_parts.join("/")
            
            img_file_name=img_num.to_s.rjust(4,"0")+".jpg"
                  
            local_img_path=File.join(vol_path,img_file_name)
            
            if !File.exist?(local_img_path)
              resp=@w.get_resp(img_page_url)
              begin
                  real_img_url=@w.get_real_img_url(resp.body)
                  if !@w.down_file(real_img_url,local_img_path)
                    @log.error(local_img_path+" fails to be saved.")        
                  end
                  # Output the dowloading messages
                  msg_pipe.append_msg("下载 "+local_img_path+" ... [完成]",img_num)
              rescue Exception=>e
                @log.error(e)
              end
            end      
        }
      end
  end
end