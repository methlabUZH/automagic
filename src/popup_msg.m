function popup_msg(msgStr, title)
% popup_msg Make a message pop up. The message pop up message will be an
% error if the title is 'Error'.
%
%   If MATLAB is not in Desktop mode, the message will be only printed and
%   now window will pop up.
%
%   The window will be positioned relative to either importResultsGUI,
%   ratingGUI or mainGUI. If ratingGUI is not available, mainGUI is
%   selected. If mainGUI is not available then importResultsGUI (from
%   eeglab plugin) is selected (An error can not occur from the mainGUI if
%   ratingGUI is already open).
%
% Copyright (C) 2017  Amirreza Bahreini, methlabuzh@gmail.com
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

if ~usejava('Desktop')
   fprintf([title ' : ' msgStr '\n']); 
   return;
end

handle = findobj(allchild(0), 'flat', 'Tag', 'ratingGUI');
if(isempty(handle))
    handle = findobj(allchild(0), 'flat', 'Tag', 'mainGUI');
end
if(isempty(handle))
    handle = findobj(allchild(0), 'flat', 'Tag', 'importResultsGUI');
end

mainPos = get(handle,'position');
if(strcmp(title, 'Error'))
    msgHandle = msgbox(msgStr, title, 'Error','modal');
else
    msgHandle = msgbox(msgStr, title, 'modal');
end
msgPos = get(msgHandle,'position');
% set(msgHandle, 'position', [mainPos(3)/2 mainPos(4)/2 msgPos(3) msgPos(4)]);
waitfor(msgHandle);