import { body, ValidationChain } from 'express-validator'; 
import { Priority } from '../enums/Priority';
import { Status } from '../enums/Status';
export const createValidator: ValidationChain[] = [
   body('title')
      .not()
      .isEmpty()
      .withMessage('The task title is mandatory')
      .trim()
      .isString()
      .withMessage('The task title needs to be a string'),
   body('date')
      .not()
      .isEmpty()
      .withMessage('Date is required')
      .trim().isString()
      .withMessage('Date needs to be a valid date format'),
   body('description')
      .isEmpty()
      .withMessage('Description is required')
      .trim()
      .isString()
      .withMessage('Description needs to be in text format'),
   body('priority')
      .isEmpty()
      .withMessage('Priority is required')
      .trim()
      .isIn([Priority.normal, Priority.high, Priority.low])
      .withMessage('Priority needs to be "normal", "high" or "low".'),
   body('status')
      .isEmpty()
      .withMessage('Status is required')      
      .trim()
      .isIn([Status.todo, Status.inProgress, Status.completed])
      .withMessage('Status needs to be "todo", "in progress" or "completed"')
];

export const updateValidator = [
   body('id')
      .not()
      .isEmpty()
      .withMessage('The task id must be provided')
      .trim()
      .isString()
      .withMessage('The id needs to be a string of uuid format'),
   body('status')      
      .trim()
      .isIn([Status.todo, Status.inProgress, Status.completed])
      .withMessage('Status needs to be "todo", "in progress" or "completed"')
];