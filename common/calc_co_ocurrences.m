function co_ocurrence = calc_co_ocurrences(hb_idx_matrix)

range_out = [0 1000];
half_win = 100;

cant_leads = length(hb_idx_matrix);

if( cant_leads == 1 )
    co_ocurrence{1} = repmat( range_out(2), length(hb_idx_matrix{1}), 1);
    return
end

comps = nchoosek(1:cant_leads,2);
co_ocurrence = cell(1,cant_leads);

% for kk = 1:cant_leads
%     co_ocurrence{kk} = zeros(length(hb_idx_matrix{kk}),1);
% end
% 
% for kk = 1:size(comps,1)
%     
%     fprintf('%d/%d\n', kk, size(comps,1))
%     aux_val1 = hb_idx_matrix{comps(kk,1)};
%     aux_val2 = hb_idx_matrix{comps(kk,2)};
%     
%     [ ~, idx_1, idx_2 ] = soft_intersect( double(aux_val1), double(aux_val2), half_win);
% 
%     aux_co_oc1 = co_ocurrence{comps(kk,1)};
%     aux_co_oc1(idx_1) = aux_co_oc1(idx_1) + 1;
%     co_ocurrence{comps(kk,1)} = aux_co_oc1;
%     
%     aux_co_oc2 = co_ocurrence{comps(kk,2)};
%     aux_co_oc2(idx_2) = aux_co_oc2(idx_2) + 1;
%     co_ocurrence{comps(kk,2)} = aux_co_oc2;
%     
% end

aux_min = min(cell2mat(cellfun(@(a)(min(a)),hb_idx_matrix, 'UniformOutput', false)));
aux_size = max(cell2mat(cellfun(@(a)(max(a)),hb_idx_matrix, 'UniformOutput', false))) - aux_min + 1;
aux_mat = zeros( aux_size, cant_leads);
aux_idx = cell2mat(cellfun(@(a,b)(colvec( (round(a) - aux_min + 1) + (b * aux_size)  ) ), colvec(hb_idx_matrix), num2cell((0:cant_leads-1)'), 'UniformOutput', false));

aux_idx = aux_idx(aux_idx > half_win & aux_idx < (numel(aux_mat) - half_win) );

for ii = -half_win:half_win
    aux_mat(aux_idx+ii) = 1;
end

co_ocurrence = cellfun( @(a)( colvec(sum(aux_mat(round(a) - aux_min + 1,:),2)+1) ), hb_idx_matrix, 'UniformOutput', false );

co_ocurrence = cellfun( @(a)( round(soft_range_conversion( a, [ 0 cant_leads-1 ], range_out, 0.25 ) ) ), co_ocurrence, 'UniformOutput', false);



