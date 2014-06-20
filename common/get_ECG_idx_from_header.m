function [ECG_idx, ECG_header ]= get_ECG_idx_from_header(ECG_header)
    
    ECG_idx = [];
    
    str_12_leads_desc = {'I' 'II' 'III' 'AVR' 'AVL' 'AVF' 'V1' 'V2' 'V3' 'V4' 'V5' 'V6' 'MLII' 'MLI' 'MLIII' 'MV1' 'MV2' 'MV3' 'MV4' 'MV5' 'MV6'};
    % add ECG patterns to be matched in ECG_header.desc
    ECG_pattern_desc = {'ECG'};

    [~, ~, aux_idx ] = intersect(str_12_leads_desc, upper(strtrim(cellstr(ECG_header.desc))) );
    
    if( ECG_header.nsig ~= length(aux_idx) )
        
        ECG_idx = colvec(aux_idx);
        
        aux_idx = find(any(cell2mat(cellfun(@(b)(cell2mat(cellfun(@(a)(~isempty(strfind(a, b))), rowvec(upper(cellstr(ECG_header.desc))), 'UniformOutput', false))), colvec(ECG_pattern_desc), 'UniformOutput', false)),1));
        
        if( isempty(aux_idx) )
            if( isempty(ECG_idx) )
                warning('get_ECG_idx_from_header:NoECGfound', disp_option_enumeration('Could not find any ECG signal, check the lead description of the recording:', cellstr(ECG_header.desc) ) );
            end
        else
            ECG_idx = [ECG_idx; colvec(aux_idx)];
            Not_ECG_idx = setdiff(1:ECG_header.nsig, ECG_idx);
            if( ~isempty(Not_ECG_idx) )
%                 warning('get_ECG_idx_from_header:SignalsDiscarded', disp_option_enumeration('Some signal/s present are not ECG:', cellstr(ECG_header.desc(Not_ECG_idx,:)) ))
            end
        end
        
    else
        % all leads are standard ECG leads
        ECG_idx = 1:ECG_header.nsig;
    end
    
    if(length(ECG_idx) ~= ECG_header.nsig && nargout > 1)
       %trim the heasig if needed 
       
       for fname = rowvec( fieldnames(ECG_header) )
           aux_val = ECG_header.(fname{1});
           [nsig, n2] = size(aux_val);
           if( nsig == ECG_header.nsig )
               % filter only the ECG_idx signals
               if( n2 > 1 )
                   ECG_header.(fname{1}) = aux_val(ECG_idx,:);
               else
                   ECG_header.(fname{1}) = aux_val(ECG_idx);
               end
           end
       end
       
       ECG_header.nsig = length(ECG_idx);
        
    end
    