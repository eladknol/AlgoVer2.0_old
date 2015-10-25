function templateSize = getQRSTemplateSize(mult)
% #codegen

% #CODER_REMOVE

% global globalConfig;
% if(isempty(globalConfig))
%     globalConfig.procType = 'maternal';
% end
% 
% if(strcmp(globalConfig.procType,'maternal'))
%     if(~nargin)
%         mult = 2;
%     end
% else
%     if(~nargin)
%         mult = 1;
%     end
% end

mult = 50*mult;
templateSize.onset  = floor(-mult);
templateSize.offset = floor(mult);
