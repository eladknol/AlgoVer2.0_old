function AlgVerificationSortFilterTable(table)
%AlgVerificationSortFilterTable filters data table according to column headers
%   

% Now turn the JIDE SORTING on
jScroll = findjobj(table);
jtable = jScroll.getViewport.getView;
jtable.setSortable(true);
jtable.setAutoResort(true);
jtable.setMultiColumnSortable(true);
jtable.setPreserveSelectionsAfterSorting(true);

% Turn FILTERING On
tableHeader = com.jidesoft.grid.AutoFilterTableHeader(jtable);
tableHeader.setAutoFilterEnabled(true)
tableHeader.setShowFilterName(true)
tableHeader.setShowFilterIcon(true)
jtable.setTableHeader(tableHeader)
installer = com.jidesoft.grid.TableHeaderPopupMenuInstaller(jtable);
pmCustomizer1=com.jidesoft.grid.AutoResizePopupMenuCustomizer;
installer.addTableHeaderPopupMenuCustomizer(pmCustomizer1);
pmCustomizer2=com.jidesoft.grid.TableColumnChooserPopupMenuCustomizer;
installer.addTableHeaderPopupMenuCustomizer(pmCustomizer2);
% jScrollPane = javax.swing.JScrollPane(jtable);
% [hjtable,hjcontainer]=javacomponent(jScrollPane,[20,20,200,150],gcf);





