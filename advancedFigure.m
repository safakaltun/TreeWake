classdef advancedFigure < matlab.mixin.SetGet
    properties
        mainFig = figure('Visible','off');
        axDim
        axList
    end
    methods
        function Obj = advancedFigure(varargin)
            
        end
    end
    methods (Static)
        function out    = get_axes_location(varargin)
            out.axList = varargin{1};
            [~,rowORcol] = max(size(out.axList));
            if rowORcol==2
                rowNum     = out.axList;
                colNum     = size(out.axList,2);
                out.axSize = sum(rowNum,2);
            else
                rowNum     = size(out.axList,1);
                colNum     = out.axList';
                out.axSize = sum(colNum,2);
            end
            hMinStart = min(1./rowNum)*0.1;
            for iRow = 1:size(rowNum,2)
                hInt       = 1/rowNum(iRow);
                hSpace     = hMinStart;
                hHalfSpace = hSpace/2;
                out.hLen(iRow)   = (1-(hMinStart*(rowNum(iRow)+1)))/rowNum(iRow);
                out.hStart{iRow,:} = [hSpace linspace(hInt,(rowNum(iRow)-1)*hInt,rowNum(iRow)-1)+hHalfSpace];
            end
            vMinStart = min(1./colNum)*0.1;
            for jCol = 1:size(colNum,2)
                vInt             = 1/colNum(jCol);
                vSpace           = vMinStart;
                vHalfSpace       = vSpace/2;
                out.vLen(jCol)   = (1-(vMinStart*(colNum(jCol)+1)))/colNum(jCol);
                out.vStart{jCol,:} = [vSpace linspace(vInt,(colNum(jCol)-1)*vInt,colNum(jCol)-1)+vHalfSpace];
            end
        end
        function axList = make_axes(figIn,axesMatrix)
            rowNum = length(axesMatrix.vLen);
            colNum = length(axesMatrix.hLen);
            
            hStart = [axesMatrix.hStart{:}];
            hLen = axesMatrix.hLen;
            if colNum == 1
                hStart = arrayfun(@(x) repmat(hStart(x),1,axesMatrix.axList(x)),1:rowNum,'uni',false);
                hStart = [hStart{:}];
                hLen   = repmat(hLen,1,axesMatrix.axSize);
            else
                hLen = arrayfun(@(x) repmat(hLen(x),1,axesMatrix.axList(x)),1:colNum,'uni',false);
                hLen = [hLen{:}];
            end
            
            
            vStart = [axesMatrix.vStart{:}];
            vLen = axesMatrix.vLen;
            
            if rowNum == 1
                vStart = arrayfun(@(x) repmat(vStart(x),1,axesMatrix.axList(x)),1:colNum,'uni',false);
                vStart = [vStart{:}];
                vLen   = repmat(vLen,1,axesMatrix.axSize);
                
            else
                vLen =  arrayfun(@(x) repmat(vLen(x),1,axesMatrix.axList(x)),1:rowNum,'uni',false);
                vLen = [vLen{:}];
                
            end
            
            clf(figIn);
            for iAxes = 1:axesMatrix.axSize
                axPos = [hStart(iAxes) vStart(iAxes) hLen(iAxes) vLen(iAxes)];
               axList.(['ax' num2str(iAxes)]) = axes(figIn,'Units','normalized','Position',axPos);
            end

        end
    end
end