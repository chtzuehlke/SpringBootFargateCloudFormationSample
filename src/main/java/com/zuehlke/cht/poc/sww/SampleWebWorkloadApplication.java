package com.zuehlke.cht.poc.sww;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import javax.sql.DataSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.amazonaws.services.simplesystemsmanagement.AWSSimpleSystemsManagement;
import com.amazonaws.services.simplesystemsmanagement.AWSSimpleSystemsManagementClientBuilder;
import com.amazonaws.services.simplesystemsmanagement.model.GetParameterRequest;

@SpringBootApplication
@RestController
@Configuration
public class SampleWebWorkloadApplication {
	final private static Logger log = LoggerFactory.getLogger(SampleWebWorkloadApplication.class);
	
	@Value("${DBAddress}")
	private String dbAddress;
	
	@Value("${DBPort}")
	private String dbPort;
	
	@Value("${DBPassSSMName}")
	private String dbPassSSMName;
	
	@Autowired
	private JdbcTemplate jdbcTemplate;

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
	
	@RequestMapping("/")
	@Transactional(readOnly=true)
    public String home() throws IOException {
		StringBuilder sb = new StringBuilder();
		try (BufferedReader in = new BufferedReader(new InputStreamReader(getClass().getResourceAsStream("/META-INF/maven/com.zuehlke.cht.poc/sample-web-workload/pom.properties")))) {
			for (String line = in.readLine(); line != null; line = in.readLine()) {
				sb.append(line);
				sb.append(", ");
			}
		}
		
		sb.append("foo.bar=" + jdbcTemplate.queryForObject("select bar from foo", Integer.class));
		
		String response = sb.toString();
		
		log.info("Home: {}", response);
		
        return response;
    }
	
	public static void main(String[] args) {
		SpringApplication.run(SampleWebWorkloadApplication.class, args);
	}
}
