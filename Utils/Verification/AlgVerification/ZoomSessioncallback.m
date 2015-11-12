function Zoomcallback(obj,event_obj,newLim,ax,lims)
   newLim = event_obj.Axes.XLim;
   Plot_Limits(ax(1),newLim,lims(1,:))
   Plot_Limits(ax(2),newLim,lims(2,:))
   Plot_Limits(ax(3),newLim,lims(3,:))
   Plot_Limits(ax(4),newLim,lims(4,:))
      
end

function Plot_Limits(ax,xlim,ylim)
   items_ax=get(ax,'Children');
   delete(items_ax(1:2));
   plot(ax,xlim(1)*[1 1],ylim,'--r');hold on;
   plot(ax,xlim(2)*[1 1],ylim,'--r');hold on;
end
  
