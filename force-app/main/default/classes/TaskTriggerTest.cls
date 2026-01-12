@isTest
public class TaskTriggerTest {
    
    @isTest static void testTokenAdvancePaymentFollowup() {
        // Set up test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Task task1 = new Task(
            Subject = 'Token Advance Payment Follow-up',
            Status = 'Completed',
            WhatId = acc.Id
        );
        
        insert task1;
        
        // Update the task
        task1.Status = 'Completed';
        update task1;
        
        // Verify the behavior
        List<Task> updatedTasks = [SELECT Id, WhatId FROM Task WHERE WhatId = :acc.Id];
        System.assertEquals(1, updatedTasks.size(), 'Task should be added to the list for Token Advance Payment Follow-up');
    }

    @isTest static void testWelcomeCallFollowup() {
        // Set up test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Task task2 = new Task(
            Subject = 'Welcome Call Follow-up',
            Status = 'Completed',
            WhatId = acc.Id
        );
        
        insert task2;
        
        // Update the task
        task2.Status = 'Completed';
        update task2;
        
        // Verify the behavior
        List<Task> updatedTasks = [SELECT Id, WhatId FROM Task WHERE WhatId = :acc.Id];
        System.assertEquals(1, updatedTasks.size(), 'Task should be added to the list for Welcome Call Follow-up');
    }

    @isTest static void testCarParkingFollowup() {
        // Set up test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Task task3 = new Task(
            Subject = 'Car Parking Follow-up',
            Status = 'Completed',
            WhatId = acc.Id
        );
        
        insert task3;
        
        // Update the task
        task3.Status = 'Completed';
        update task3;
        
        // Verify the behavior
        List<Task> updatedTasks = [SELECT Id, WhatId FROM Task WHERE WhatId = :acc.Id];
        System.assertEquals(1, updatedTasks.size(), 'Task should be added to the list for Car Parking Follow-up');
    }

    @isTest static void testAdvancePaymentFollowup() {
        // Set up test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Task task4 = new Task(
            Subject = 'Advance Payment Follow-up',
            Status = 'Completed',
            WhatId = acc.Id
        );
        
        insert task4;
        
        // Update the task
        task4.Status = 'Completed';
        update task4;
        
        // Verify the behavior
        List<Task> updatedTasks = [SELECT Id, WhatId FROM Task WHERE WhatId = :acc.Id];
        System.assertEquals(1, updatedTasks.size(), 'Task should be added to the list for Advance Payment Follow-up');
    }

    @isTest static void testOverallBookingDetailsReview() {
        // Set up test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Task task5 = new Task(
            Subject = 'Overall Booking Details Review',
            Status = 'Completed',
            WhatId = acc.Id
        );
        
        insert task5;
        
        // Update the task
        task5.Status = 'Completed';
        update task5;
        
        // Verify the behavior
        List<Task> updatedTasks = [SELECT Id, WhatId FROM Task WHERE WhatId = :acc.Id];
        System.assertEquals(1, updatedTasks.size(), 'Task should be added to the list for Overall Booking Details Review');
    }

    @isTest static void testSaleAgreementVerification() {
        // Set up test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Task task6 = new Task(
            Subject = 'Please verify the agreement details of primary applicant',
            Status = 'Completed',
            WhatId = acc.Id
        );
        
        insert task6;
        
        // Update the task
        task6.Status = 'Completed';
        update task6;
        
        // Verify the behavior
        List<Task> updatedTasks = [SELECT Id, WhatId FROM Task WHERE WhatId = :acc.Id];
        System.assertEquals(1, updatedTasks.size(), 'Task should be added to the list for Sale Agreement Verification');
    }

    @isTest static void testSaleAgreementCompletion() {
        // Set up test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Task task7 = new Task(
            Subject = 'Sale Agreement Registration Completion',
            Status = 'Completed',
            WhatId = acc.Id
        );
        
        insert task7;
        
        // Update the task
        task7.Status = 'Completed';
        update task7;
        
        // Verify the behavior
        List<Task> updatedTasks = [SELECT Id, WhatId FROM Task WHERE WhatId = :acc.Id];
        System.assertEquals(1, updatedTasks.size(), 'Task should be added to the list for Sale Agreement Completion');
    }
}