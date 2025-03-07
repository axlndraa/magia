function modeling_options = aivo_read_logan_modeling_options(subject_id)

conn = check_megabase_conn();
if(isempty(conn))
    conn = aivo_connect();
end

cols = aivo_columns(conn,'logan');
cols = setdiff(cols,'tracer','stable');
M = length(cols);
select_statement = 'SELECT * FROM "megabase"."aivo2".logan';
where_statement = sprintf('WHERE logan.image_id = %s%s%s',char(39),lower(subject_id),char(39));

q = sprintf('%s %s ORDER BY image_id ASC;',select_statement,where_statement);

curs = exec(conn,q);
curs = fetch(curs);
close(curs);
value = curs.Data;
close(conn);

modeling_options.model = 'logan';
tracer = aivo_get_info(subject_id,'tracer');
if(iscell(tracer))
    tracer = tracer{1};
end

for i = 2:M
    var = cols{i};
    switch var
        case 'start_time'
            start_time = value{1,i};
            if(isnan(start_time))
                start_time = magia_get_logan_default_options(tracer,var);
            end
        case 'end_time'
            end_time = value{1,i};
            if(isnan(end_time))
                end_time = magia_get_logan_default_options(tracer,var);
            end
    end
end

modeling_options.start_time = start_time;
modeling_options.end_time = end_time;

aivo_set_modeling_options(subject_id,modeling_options);

end
