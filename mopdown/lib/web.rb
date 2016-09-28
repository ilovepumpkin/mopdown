require 'model'
require 'net/http'
require 'mylogger'

module Web
class WebRetriever
   include Net
   include Model
   include Logging
   
   MOP_HOST="http://dm.game.mop.com"
   
   TRY_TIMES=10
   
  def initialize
      @log=MyLogger.new
  end
    
  def get_resp url
     tried_times=1
     done_flag=false
     resp=nil
     while !done_flag && tried_times<=TRY_TIMES
          begin
            resp=HTTP.get_response(URI.parse(url))
            done_flag=true
            rescue Exception=>e
            @log.error(e)            
            @log.error("Fail to get response from "+url+" for "+tried_times.to_s+", retry another time.")      
            tried_times=tried_times+1
          end
        end
      if !done_flag
          bye_msg= "重试次数超过最大限制("+TRY_TIMES.to_s+"次),仍无法获得"+url+"的响应。请检查网络是否正常或增大最大限制次数值。"
          @log.error(bye_msg)
          puts bye_msg
        end
     return resp   
   end
  
  def get_subcat_by_letter letter
        first_page_url=full_url("/classSearch/"+letter+"/1.html")
        page_urls=get_page_urls(first_page_url)
        
        subcat=SubCat.new
        subcat.letter=letter
        
        page_urls.each_index{|i|
          url=page_urls[i]        
          page=SubCatPage.new
          page.thumb_list=get_thumbs(url)
          page.page_num=i
          subcat.add_page page
        }
        
        return subcat
    end
      
    def get_page_urls page_url
        page_urls=Array.new
        resp=get_resp(page_url)
        re1=/(\/classSearch.*$)/
        page_url=~re1
        page_urls<<full_url($1)
        
        re2=/<a href="([\/|.|\w]+)" class=>\d<\/a>/
        resp.body.gsub(re2){|match|
         page_urls<<full_url($1)
        }
        page_urls
    end
  
  def full_url url_part
      MOP_HOST+url_part
    end

  def get_thumbs catpage_url        
        cat_urls=Array.new(0)
        img_urls=Array.new(0)
        resp=get_resp(catpage_url)        
        re1=/<div class="tukuang"><a href="(.*)"><img src="(.*)" width="110" height="164"\/><\/a><\/div>/
        resp.body.gsub(re1){|match|           
           cat_url=MOP_HOST+$1
           cat_urls<<cat_url
           img_urls<<$2
        }
        
        cat_names=Array.new
        re2=/<p class="fb chui pad5 textcen p12">(.*)<\/p>/
        resp.body.gsub(re2){|match|
          cat_names<<$1
        }
        
        all_thumbs=Array.new  
        cat_urls.each_index{|i|
          thumb=Thumb.new
          thumb.book_name=cat_names[i]
          thumb.book_index_url=cat_urls[i]
          thumb.img_url=img_urls[i]                    
          add_vols_thumbinfo(thumb)
          all_thumbs<<thumb
        }  
        return all_thumbs
      end
      
      def add_vols_thumbinfo thumb
        resp=get_resp(thumb.book_index_url)
        #add volumn list
        re1=/(<a href=".*" class="f14 cblack" target="_blank">.*<\/a>)/
        resp.body=~re1
        data_list=$1.split("</li><li>")
        
        vols=Array.new
        re2=/<a href="(.*)" class="f14 cblack" target="_blank">(.*)<\/a>/
        data_list.each{|item|
          item.gsub(re2){|match|
             vol=Volumn.new
             vol.vol_name=$2.slice($2.index(">")+1,$2.length)
             vol.vol_url=MOP_HOST+$1
             vol.page_count=get_vol_page_count(vol.vol_url)
             vols<<vol
          }
        }  
        thumb.vols=vols
        
        #add additional thumb info
        re3=/<a href=".*" class="cgery">(.*)<\/a>/
        resp.body=~re3
        thumb.author=$1
        
        re4=/<p class="lh24 cgery" style="width:345px;">(.*)<\/p>/
        resp.body=~re4
        thumb.abstract=$1
        
        return thumb
      end
      
      def down_file url,file_path
        #~ Thread.new do 
        if File.exist?(file_path)
          puts "文件"+file_path+"已存在，跳过"
          return true
        end  
        
        begin
          resp=get_resp(url)          
          resp.value
          open(file_path,"wb"){|os|
            os.write(resp.body)
          }
          rescue Exception=>e  
            @log.error(url)
            @log.error(e)
            return false
          end
          return true
        #~ end
      end
      
      def get_real_img_url html
        re=/<img src="(http:\/\/[\w.\/]*upload.*\.jpg)"/
        html=~re
        $1
      end
            
      def get_vol_page_count url
        resp=get_resp(url)
        re=/<option value="\/primary\/.*\/(.*).html#pic"/
        resp.body.scan(re).last.to_s.to_i+1
      end
    end
end    