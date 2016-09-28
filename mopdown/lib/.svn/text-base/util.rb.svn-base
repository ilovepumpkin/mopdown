require 'service'
require 'singleton'
require 'thread'
require 'persister'
require 'web'

module Util
  class SearchUtil
     include Singleton
    
     def initialize
         @service=Service::FileDataService.instance
         @si=@service.load_search_index
     end
      
    def search_byname key
         @si.match_name(key)
       end
       
    def get_search_index
      return @si
    end      

  end
  
  class FileUtil
    include Singleton
    
    def delete_dir dir
      Dir.foreach(dir){|f|
         file_path=File.join(dir,f)
         if f!="." && f!=".."
           if FileTest.file?(file_path)
             File.delete(file_path)
           else
             if Dir.entries(file_path).size>2
               delete_dir(file_path)
             else
               Dir.delete(file_path)
             end  
           end
         end
      }
      Dir.delete(dir)
    end

  end
  
  class CatalogDownHelper
    def initialize range,msg_pipe
      @web=Web::WebRetriever.new
      @persister=Persister::FilePersister.new
      @msg_pipe=msg_pipe
      
      @thgrp=ThreadGroup.new
      @flag=true
      
      @range=range
      @range=('a'..'z') if @range==nil
      
    end
    
    def clean
      if(@persister.task_queue_exists?)
          puts "清除下载临时文件..."      
          @persister.delete_task_queue
      end
    end
    
    def start worker_count,inc_cover
        if(@que==nil)
            @que=build_queue(@msg_pipe)
            @que_bak=dup_queue(@que)
            @total_num=@que.length
        end     
        que_resume=dup_queue(@que_bak)    
        @flag=true
        @thgrp.list.clear
        down_cat(que_resume,worker_count,@thgrp,@msg_pipe,inc_cover)
    end
    
    def stop
      if(@que==nil)
        @msg_pipe.put("对不起,准备下载任务列表时无法暂停.")
        return false
      end  
      @flag=false    
      @end=false       
      while !@end do     
        @end=true
        @thgrp.list.each{|t|   
              @end=@end&t.stop?
        }
        if !@end          
          sleep(0.1)
        end  
      end
      return true
    end
    
    def down_cat que,worker_count,thgrp,msg_pipe,inc_cover
      msg_pipe.put("开始下载目录...[线程数:#{worker_count}]")
      workers=Range.new(1,worker_count.to_i).map do |num|
           th=Thread.new("##{num}") do |name|
              while @flag do 
                task=que.deq
                if task==:END_OF_WORK
                   clean
                   break
                end                
                local_file=task["local_file"]
                page_url=task["page_url"]
                page_num=task["page_num"]
                letter=task["letter"]
                
                msg_pipe.put("[#{name}] 正在处理 #{page_url}")
                page=SubCatPage.new                
                page.thumb_list=@web.get_thumbs(page_url)
                page.page_num=page_num
                page.letter=letter                
                @persister.save_page(page,inc_cover)
                curr_num=que.length
                percent=curr_num.to_f/@total_num.to_f
                text="#{curr_num}/#{@total_num}"
                msg_pipe.put("[#{name}]下载 "+local_img_path+" ... [完成]",percent,text)
              end
            end
            thgrp.add(th)
            
        end
        workers.size.times{@que.enq(:END_OF_WORK)}
        workers.each{|w| w.join}
      end
      
    def dup_queue que
      que_copy=Queue.new
      que_arr=Array.new
      until que.length<=0
        que_arr<<que.pop
      end
      que_arr.each{|task|
          que.enq(task)
          que_copy.enq(task)
      }
      return que_copy
    end      
    
    def build_queue msg_pipe
      msg_pipe.put("正在准备下载任务列表...")
      
      que=@persister.load_task_queue
      if que!=nil
        msg_pipe.put("发现未完成的下载任务列表")
        return que
      end

      que=Queue.new
      @range.each{|letter|        
          first_page_url=@web.full_url("/classSearch/"+letter+"/1.html")
          page_urls=@web.get_page_urls(first_page_url)          
          page_urls.each_index{|i|
            url=page_urls[i]        
            task=Hash.new
            task["page_url"]=url
            task["letter"]=letter
            task["page_num"]=i.to_s
            task["local_file"]=@persister.get_catpage_path(letter,i)
            
            que.enq(task)
          }
          msg_pipe.put("字母 #{letter} 任务列表就绪")
      }      
      msg_pipe.put("所有下载任务列表准备就绪")
      que_copy=dup_queue(que)
      @persister.save_task_queue(que_copy)
      return que
    end
 end   
  
  class VolDownHelper
    
    def initialize vol,msg_pipe
      @p=Persister::FilePersister.new
      @msg_pipe=msg_pipe
      @thgrp=ThreadGroup.new
      @flag=true
      @total_num=vol.page_count
      @curr_num=0
      @queue=prepare_vol_down_queue(vol,@msg_pipe)
    end
    
    def start worker_count
      @flag=true
      @thgrp.list.clear
      Thread.new do
          down_vol(@queue,worker_count,@thgrp,@msg_pipe)
      end
    end
    
    def stop 
      @flag=false    
      @end=false       
      while !@end do     
        @end=true
        @thgrp.list.each{|t|   
              @end=@end&t.stop?
        }
        if !@end          
          sleep(0.1)
        end  
      end
    end
    
    def prepare_vol_down_queue vol,msg_pipe
        # Prepare the download job queue
        book_path=@p.book_path(vol.book_name)
        Dir.mkdir(book_path) unless File.exists?(book_path)
        
        vol_path=@p.vol_path(vol)
        Dir.mkdir(vol_path) unless File.exists?(vol_path)
        
        vol_page_url=vol.vol_url
        
        url_parts=vol_page_url.split("/")
        last_part=url_parts.last
    
        msg_pipe.put("正在准备下载队列......")
        q=Queue.new
        @total_num.to_s.to_i.times{|img_num|        
            new_last_part=last_part.sub(/.html/,"/"+img_num.to_s+".html")
            url_parts[url_parts.size-1]=new_last_part
            img_page_url=url_parts.join("/")
            
            img_file_name=img_num.to_s.rjust(4,"0")+".jpg"
            local_img_path=File.join(vol_path,img_file_name)
            
            if !File.exist?(local_img_path)
                data=Hash.new()
                data["path"]=local_img_path
                data["url"]=img_page_url
                data["num"]=img_num
                q.enq(data)
            else
                @curr_num=@curr_num+1
            end
        }
        return q
    end
    
    def down_vol q,job_count,thgrp,msg_pipe=nil
        workers=Range.new(1,job_count.to_i).map do |num|
           th=Thread.new("##{num}") do |name|
              while @flag do
                 job=q.deq
                 if job==:END_OF_WORK
                   break
                 end
                local_img_path=job["path"]
                @p.down_img_page(job["url"],local_img_path)
                 # Output the dowloading messages
                @curr_num=@curr_num+1
                percent=@curr_num.to_f/@total_num.to_f
                text="#{@curr_num}/#{@total_num}"
                msg_pipe.put("[#{name}]下载 "+local_img_path+" ... [完成]",percent,text)
              end
            end
            thgrp.add(th)
         end
         
        workers.size.times{q.enq(:END_OF_WORK)}
        workers.each{|w| w.join}
    end
    
  end 
  
end