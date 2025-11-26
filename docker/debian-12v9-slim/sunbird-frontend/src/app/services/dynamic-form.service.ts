import { Injectable } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { DynamicFormField } from '../lib/dynamic-form';


@Injectable({
    providedIn: 'root'
})
export class DynamicFormService {

    constructor() { }

    toFormGroup(questions: DynamicFormField[]) {
        const group: any = {}
        questions.forEach((question) => {
            group[question.name] = question.required ?
                new FormControl(question.value || '', Validators.required)
                : new FormControl(question.value || '')
        })
        return new FormGroup(group);
    }
}
