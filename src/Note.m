%% Note
% Used to represent a musical note.
classdef Note
    properties
        source;     % the notes source
        effect;     % the notes effect
        type;       % the notes type
        tone;       % the tone of the note
        settings;   % extra note settings
    end    
    
    methods
        %% Note(source_in, effect_in, type_in, tone_in, settings_in_
        % Note constructor. Instantiate an instance of the Note class.
        function obj = Note(source_in, effect_in, type_in, ...
                                tone_in, settings_in)
            obj.source = source_in;
            obj.effect = effect_in;
            obj.type = type_in;
            obj.tone = tone_in;
            obj.settings = settings_in;
        end
    end
end

