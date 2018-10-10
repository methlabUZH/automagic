function popup_msg(msgStr, title)

handle = findobj(allchild(0), 'flat', 'Tag', 'ratingGUI');
if(isempty(handle))
    handle = findobj(allchild(0), 'flat', 'Tag', 'mainGUI');
end
mainPos = get(handle,'position');
if(strcmp(title, 'Error'))
    msgHandle = msgbox(msgStr, title, 'Error','modal');
else
    msgHandle = msgbox(msgStr, title, 'modal');
end
msgPos = get(msgHandle,'position');
set(msgHandle, 'position', [mainPos(3)/2 mainPos(4)/2 msgPos(3) msgPos(4)]);
waitfor(msgHandle);