package com.zuehlke.cht.poc.sww;

import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import com.amazonaws.services.simplesystemsmanagement.AWSSimpleSystemsManagement;
import com.amazonaws.services.simplesystemsmanagement.AWSSimpleSystemsManagementClientBuilder;
import com.amazonaws.services.simplesystemsmanagement.model.GetParameterRequest;

@Profile("aws")
@Configuration
public class AWSConfig {
	@Value("${DBAddress}")
	private String dbAddress;
	
	@Value("${DBPort}")
	private String dbPort;
	
	@Value("${DBPassSSMName}")
	private String dbPassSSMName;
	
	@Bean
    public DataSource getDataSource() {
		AWSSimpleSystemsManagement ssm = AWSSimpleSystemsManagementClientBuilder.defaultClient();
		String dbPass = ssm.getParameter(new GetParameterRequest().withName(dbPassSSMName).withWithDecryption(true)).getParameter().getValue();
		
        @SuppressWarnings("rawtypes")
		DataSourceBuilder dataSourceBuilder = DataSourceBuilder.create();
        dataSourceBuilder.driverClassName("com.mysql.cj.jdbc.Driver");
        dataSourceBuilder.url("jdbc:mysql://" + dbAddress + ":" + dbPort + "/db");
        dataSourceBuilder.username("masteruser");
        dataSourceBuilder.password(dbPass);
        return dataSourceBuilder.build();
    }
}
