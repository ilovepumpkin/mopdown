require 'tk'
require 'ui/tk/util'
require 'ui/tk/widgets'

module TkUi
   class HelpWin
     
         def initialize root
             @r=Window.new('title'=>"帮助")
             @r.focus()
             g=TkUtil.center(root,200,200)
             @r.geometry(g)
             
             TkLabel.new(@r,:text=>'F1:弹出帮助窗口',:font=>@@font,:relief=>'groove',:justify=>'left').pack(:side=>'top',:padx=>5,:pady=>3,:fill=>'x',:anchor=>'w')
             TkLabel.new(@r,:text=>'Esc:还原窗口',:font=>@@font,:justify=>'left',:relief=>'groove').pack(:side=>'top',:padx=>5,:pady=>3,:fill=>'x',:anchor=>'w')
             TkLabel.new(@r,:text=>'Ctrl+F4:关闭窗口',:font=>@@font,:justify=>'left',:relief=>'groove').pack(:side=>'top',:padx=>5,:pady=>3,:fill=>'x',:anchor=>'w')
             TkLabel.new(@r,:text=>'PgUp:上一页',:font=>@@font,:justify=>'left',:relief=>'groove').pack(:side=>'top',:padx=>5,:pady=>3,:fill=>'x',:anchor=>'w')
             TkLabel.new(@r,:text=>'PgDn:下一页',:font=>@@font,:justify=>'left',:relief=>'groove').pack(:side=>'top',:padx=>5,:pady=>3,:fill=>'x',:anchor=>'w')
             TkLabel.new(@r,:text=>'方向键“上”:向上滚动漫画',:font=>@@font,:justify=>'left',:relief=>'groove').pack(:side=>'top',:padx=>5,:pady=>3,:fill=>'x',:anchor=>'w')
             TkLabel.new(@r,:text=>'方向键“下”:向下滚动漫画',:font=>@@font,:justify=>'left',:relief=>'groove').pack(:side=>'top',:padx=>5,:pady=>3,:fill=>'x',:anchor=>'w')
             TkLabel.new(@r,:text=>'方向键“左”:向左滚动漫画',:font=>@@font,:justify=>'left',:relief=>'groove').pack(:side=>'top',:padx=>5,:pady=>3,:fill=>'x',:anchor=>'w')
             TkLabel.new(@r,:text=>'方向键“右”:向右滚动漫画',:font=>@@font,:justify=>'left',:relief=>'groove').pack(:side=>'top',:padx=>5,:pady=>3,:fill=>'x',:anchor=>'w')
          
             @r.bind("KeyPress-Escape",proc{@r.withdraw})
          end 
           
   end
end