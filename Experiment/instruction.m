function fh=instruction(fh, text, key)
flag=0;
figure(fh)
while flag==0
    htext_ca  = uicontrol('Style','text','FontName','Arial', 'String',text,'Units','normalized', ...
        'BackgroundColor','w','ForegroundColor',[0. 0. 0.],'Position',[0.1, 0.05, 0.8, 0.9],'FontSize',...
        32,'FontWeight', 'bold', 'HorizontalAlignment', 'left');
    uiwait(fh);
    ch = get(fh, 'Userdata');
    if ch==double(key)
        flag=1;
    else
        close all
        fh=getkeyn;
        figure(fh)
    end
end
delete(htext_ca);
drawnow;
end
