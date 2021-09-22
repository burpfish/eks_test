package com.burfordfc.service.TestService;


import com.martensigwart.fakeload.FakeLoad;
import com.martensigwart.fakeload.FakeLoadExecutor;
import com.martensigwart.fakeload.FakeLoadExecutors;
import com.martensigwart.fakeload.FakeLoads;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

import java.util.concurrent.TimeUnit;

@Configuration
@EnableScheduling
public class ScheduledBusyness {
    private static final Logger logger = LoggerFactory.getLogger(ScheduledBusyness.class);
    private static final FakeLoadExecutor executor = FakeLoadExecutors.newDefaultExecutor();

    @Scheduled(cron = "0 */10 * * * ?")
    public void scheduleFixedDelayTask() {
        logger.info("Starting busy!");

		FakeLoad fakeload = FakeLoads.create()
				.lasting(5, TimeUnit.MINUTES)
				.withCpu(80);
        executor.execute(fakeload);

        logger.info("Stopping busy!");
    }
}
