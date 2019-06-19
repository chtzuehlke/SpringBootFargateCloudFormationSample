package com.zuehlke.cht.poc.sww;

import javax.sql.DataSource;

import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

@Profile("!aws")
@Configuration
public class LocalConfig {
	@Bean
    public DataSource getDataSource() {
        @SuppressWarnings("rawtypes")
		DataSourceBuilder dataSourceBuilder = DataSourceBuilder.create();
        dataSourceBuilder.driverClassName("org.h2.Driver");
        dataSourceBuilder.url("jdbc:h2:mem:db1");
        dataSourceBuilder.url("jdbc:h2:file:./testdb");
        dataSourceBuilder.username("sa");
        dataSourceBuilder.password("");
        return dataSourceBuilder.build();
    }
}
