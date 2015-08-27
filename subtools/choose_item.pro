; Source http://www.idlcoyote.com/widget_tips/listselection.html

PRO Choose_Item_Event, event

   ; Get info structure pointer.
   Widget_Control, event.top, Get_UValue=ptr

   ; Get the item from the list widget and store it
   ; in the program pointer.
   Widget_Control, event.id, Get_UValue=listValues
   (*ptr).answer = listValues[event.index]
   (*ptr).cancel = 0

   ; Destroy the widget.
   Widget_Control, event.top, /Destroy

END ; ----------------------------------------------------


FUNCTION Choose_Item, items, Cancel=cancel, Group_Leader=group_leader

   IF N_Elements(items) EQ 0 THEN items = ['cow', 'dog', 'coyote', 'pig']

   ; Create the top-level base widget. Make it modal if you
   ; have a group_leader. Otherwise, will have to rely on this
   ; widget blocking. If so, DON'T call it from a widget program!
   IF N_Elements(group_leader) EQ 0 THEN BEGIN
      tlb = Widget_Base(Title='Select Variable', Column=1)
   ENDIF ELSE BEGIN
      tlb = Widget_Base(Title='Select Variable', Column=1, /Modal, Group_Leader=group_leader)
   ENDELSE

   ; Create list widget with choices. Store the choices in the UVALUE
   ; of the list, so they are available in the event handler.
   listID = Widget_List(tlb, Value=items, UValue=items, YSize=N_Elements(items) < 50, XSize=55)

   ; Create a pointer for storing the user's selection. There is a cancel
   ; flag so I can tell if user killed the widget without making a selection.
   ptr = Ptr_New({answer:"", cancel:1})

   ; Store info pointer in UVALUE of TLB.
   Widget_Control, tlb, Set_UValue=ptr

   ; Realize the widgets.
   Widget_Control, tlb, /Realize

   ; Call XManager and BLOCK the command line. This will only work
   ; if this is the FIRST blocking program. Use GROUP_LEADER and MODAL
   ; keyword to be *sure* you block.
   XManager, 'choose_item', tlb

   ; Get the answer and cancel flag out of the program pointer and destroy the pointer.
   answer = (*ptr).answer
   cancel = (*ptr).cancel
   Ptr_Free, ptr

   ; Return the answer.
   RETURN, answer

END