function respond(userConfig)


switch lower(userConfig.product)
    case 'beats',
        RitmoBeatsMain(userConfig.type);
    case 'moments',
        RitmoMomentsMain(userConfig.type);
    case 'duet',
        RitmoDuetMain(userConfig.type);     
    otherwise
        disp('Not supported yet');
        return;
end