function writeStruct2XML(fileName, dataStruct, root_element_name)

if(nargin<3)
    root_element = 'root_element';
else
    root_element = root_element_name;
end

docNode = com.mathworks.xml.XMLUtils.createDocument(root_element);
docRootNode = docNode.getDocumentElement;
% docRootNode.setAttribute('attribute','attribute_value');

% get fields to write
Fields_1 = fields(dataStruct);
for i=1:length(Fields_1)
    fieldName = Fields_1{i};
    parseChildNodes(fieldName, dataStruct, docNode, docRootNode);
end

docNode.appendChild(docNode.createComment('this is a comment'));

% Save the sample XML document.
xmlFileName = [fileName,'.xml'];
xmlwrite(xmlFileName,docNode);
edit(xmlFileName);


function parseChildNodes(fieldName, data, docNode, docRootNode)

if(~isstruct(data.(fieldName)))
    thisElement = docNode.createElement(fieldName);
    if(isnumeric(data.(fieldName)))
        valStr = num2str(data.(fieldName)(:)');
        SIZE = size(data.(fieldName));
        if((SIZE(1)>1 && SIZE(2)>1) || length(SIZE)>2)
            node.data = valStr;
            node.size = num2str(SIZE(:)'); 
            docRootNode.appendChild(thisElement);
            parseChildNodes('data', node, docNode, thisElement);
            parseChildNodes('size', node, docNode, thisElement);
            return;
        end
    else
        if(iscell(data.(fieldName)))
            valStr=[];
            for i=1:length(data.(fieldName))
                valStr = [valStr data.(fieldName){i} ','];
            end
            if(~isempty(valStr))
                valStr(end) = [];
            end
        else
            valStr = data.(fieldName);
        end
    end
    thisElement.appendChild(docNode.createTextNode(valStr));
    thisElement.setAttribute('attribute','attribute_value');
    docRootNode.appendChild(thisElement);
else
    Fields_2 = fields(data.(fieldName));    
    mainElement = docNode.createElement(fieldName);
    docRootNode.appendChild(mainElement);
    mainElement.appendChild(docNode.createComment([ fieldName ' child elements']));
    
    for j=1:length(Fields_2)
        fieldName_2 = Fields_2{j};
        parseChildNodes(fieldName_2, data.(fieldName), docNode, mainElement);
    end
end
