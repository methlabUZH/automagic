classdef ImportParams < handle
	properties
		selectedList
        project
	end
	
	methods
		function self = ImportParams(selectedList)
			self.selectedList = selectedList;
		end
	end
end