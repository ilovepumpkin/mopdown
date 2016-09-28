module TkUi

     class TkUtil
       def TkUtil.center rel_obj,width,height
          geo_root=rel_obj.geometry
          wh,x,y=geo_root.split('+')
          w,h=wh.split('x')
          ox=Integer(x)+(Integer(w)-width)/2
          oy=Integer(y)+(Integer(h)-height)/2
          og=String(width)<<'x'<<String(height)<<'+'<<String(ox)<<'+'<<String(oy)
        end
        
        def TkUtil.screen_center widget,width,height
          screenheight=TkWinfo.screenheight(widget)
          screenwidth=TkWinfo.screenwidth(widget)
          ox=(screenwidth.to_i-width)/2
          oy=(screenheight.to_i-height)/2
          og=String(width)<<'x'<<String(height)<<'+'<<String(ox)<<'+'<<String(oy)
          widget.geometry(og)
        end
        
        def TkUtil.fullscreen widget
          screenheight=TkWinfo.screenheight(widget)
          screenwidth=TkWinfo.screenwidth(widget)
          ox=0
          oy=0
          og=String(screenwidth)<<'x'<<String(screenheight)<<'+'<<String(ox)<<'+'<<String(oy)
          widget.geometry(og)
        end
        
      end

end