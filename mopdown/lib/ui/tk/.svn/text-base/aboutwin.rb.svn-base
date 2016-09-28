require 'tk'
require 'ui/tk/util'
require 'ui/tk/widgets'

module TkUi
   class AboutWin
      def initialize root
         r=Window.new('title'=>"关于")
         g=TkUtil.center(root,250,130)
         r.geometry(g)
         
         close_btn=TkButton.new(r,'text'=>'关闭','font'=>@@font).pack('side'=>'bottom','pady'=>10)
         close_btn.command=lambda{
           r.withdraw
         }
  
         logo=TkPhotoImage.new{file File.join($image_dir,'logo.gif')}
         TkLabel.new(r,'image'=>logo).pack('side'=>'left','padx'=>10,'pady'=>10)
         intro=TkText.new(r){
           pack 'side'=>'right','pady'=>10
           background '#ece9d8'
           relief 'flat'
           font @@font
         }
         intro.insert("1.0","MopDown 是一款用于下载和管理漫画书的开源软件。了解更多，请访问 http://code.google.com/p/mopdown/ 。有任何问题和建议，请联系QQ:330521。")
                  
         
      end
   end
end