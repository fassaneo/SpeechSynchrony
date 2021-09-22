%% Getkey
% ------
% Toma caracter de teclado a partir de una ventana activa.
% - Si se llama sin argumentos, devuelve el handle para la ventana de input
% - En llamadas posteriores, para tomar el caracter ascii, se llama poniendo
% como argumento ese handle.
% Ejemplo al inicio del programa:
%           fh = getkey;
% Almacena en fh el handle para la ventana de respuesta. Luego mas adelante
%           R  = getkey(fh)
% Toma el caracter del teclado y devuelve su valor ascii en R.


%%
function ch = getkeyn(fh, optext, helptext,colorscr, size1, size2)

	switch nargin
        case 0
            screen=get(0,'ScreenSize');
            callstr = ['set(gcbf,''Userdata'',double(get(gcbf,''Currentcharacter''))) ; uiresume '] ;
            fh = figure('keypressfcn',callstr, ...
                'menubar','none',...
                'windowstyle','normal',...    
                'Name',' ', ...
                'Color','w', ...
                'Position',screen, ...
                'userdata','timeout') ;
            ch = fh;
        case 6
            figure(fh)
            htext_ca  = uicontrol('Style','text','FontName','Courier', 'String',optext,'Units','normalized', ...
                'BackgroundColor','w','ForegroundColor',colorscr,'Position',[0.1, 0.6, 0.9, 0.4],'FontSize',size1,'HorizontalAlignment', 'left');
            htext_zz  = uicontrol('Style','text','String',helptext,'FontName','Courier','Units','normalized', ...
                'BackgroundColor','w','ForegroundColor',colorscr,'Position',[0.1, 0.1, 0.8, 0.5],'FontSize',size2,'HorizontalAlignment', 'left');
            
            try
                uiwait(fh);
                ch = get(fh, 'Userdata');
                if isempty(ch),
                    ch = NaN;
                end
            catch
                ch = [] ;
            end
            
            delete(htext_ca);
            delete(htext_zz);
            drawnow;
    end
end


