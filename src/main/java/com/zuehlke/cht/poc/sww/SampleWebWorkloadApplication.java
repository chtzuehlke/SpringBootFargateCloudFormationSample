package com.zuehlke.cht.poc.sww;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
@Configuration
public class SampleWebWorkloadApplication {
	final private static Logger log = LoggerFactory.getLogger(SampleWebWorkloadApplication.class);
	
	@Autowired
	private JdbcTemplate jdbcTemplate;

	@RequestMapping("/")
	@Transactional(readOnly=true)
    public String home() throws IOException {
		StringBuilder sb = new StringBuilder();
		try (BufferedReader in = new BufferedReader(new InputStreamReader(getClass().getResourceAsStream("/META-INF/maven/com.zuehlke.cht.poc/sample-web-workload/pom.properties")))) {
			for (String line = in.readLine(); line != null; line = in.readLine()) {
				sb.append(line);
				sb.append(", \n");
			}
		}
		
		sb.append("(version2) foo.bar=" + jdbcTemplate.queryForObject("select bar from foo", Integer.class));
		
		String response = sb.toString();
		
		log.info("Home: {}", response);
		
        return response + "\n";
    }
	
	public static void main(String[] args) {
		SpringApplication.run(SampleWebWorkloadApplication.class, args);
	}
}
