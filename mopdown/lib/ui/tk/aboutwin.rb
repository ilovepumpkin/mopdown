require 'tk'
require 'ui/tk/util'
require 'ui/tk/widgets'

module TkUi
   class AboutWin
      def initialize root
         r=Window.new('title'=>"����")
         g=TkUtil.center(root,250,130)
         r.geometry(g)
         
         close_btn=TkButton.new(r,'text'=>'�ر�','font'=>@@font).pack('side'=>'bottom','pady'=>10)
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
         intro.insert("1.0","MopDown ��һ���������غ͹���������Ŀ�Դ������˽���࣬����� http://code.google.com/p/mopdown/ �����κ�����ͽ��飬����ϵQQ:330521��")
                  
         
      end
   end
end