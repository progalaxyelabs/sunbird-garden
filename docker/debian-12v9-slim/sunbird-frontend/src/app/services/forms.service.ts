import { Injectable } from '@angular/core';
import { DynamicForm } from '../lib/dynamic-form';


type DynamicFormsMap = { [key: string]: DynamicForm }
export type FormNames = { key: string, name: string }[]

@Injectable({
    providedIn: 'root'
})
export class FormsService {

    private forms: Map<string, DynamicForm>

    constructor() {
        this.forms = new Map()
    }

    add(form: DynamicForm): boolean {
        const key = form.formName.trim().toLowerCase().replace(/[^a-z0-9_]/g, '')
        console.log(`FormService::add - key is ${key}`)
        if (this.forms.has(key)) {
            console.warn('FormService: A form with similar name exists')
            return false
        }

        this.forms.set(key, form)
        console.log('added form')
        return true
    }

    find(key: string): DynamicForm | undefined {
        return this.forms.get(key)
    }

    names(): FormNames  {
        const a = []
        for (let [key, form] of this.forms) {
            a.push({ key: key, name: form.formName })
        }        
        return a
    }
}
