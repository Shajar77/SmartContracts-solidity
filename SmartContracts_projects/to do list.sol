// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ToDoList {
    // A task with a description and completion status
    struct Task {
        string description;
        bool isCompleted;
    }

    // Array to store tasks
    Task[] public tasks;

    // Add a new task
    function addTask(string memory _description) public {
        tasks.push(Task(_description, false)); // Add a new task as incomplete
    }

    // Mark a task as completed
    function completeTask(uint _taskId) public {
        require(_taskId < tasks.length, "Task does not exist.");
        tasks[_taskId].isCompleted = true;
    }

    // Get the total number of tasks
    function getTaskCount() public view returns (uint) {
        return tasks.length;
    }
}
