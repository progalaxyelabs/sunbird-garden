import { Component } from '@angular/core';
import { DynamicFormComponent } from "../../components/dynamic-form/dynamic-form.component";
import { DynamicForm, DynamicFormButton, DynamicFormField, DynamicFormFieldType } from '../../lib/dynamic-form';

@Component({
    selector: 'app-contact',
    standalone: true,
    imports: [DynamicFormComponent],
    templateUrl: './contact.component.html',
    styleUrl: './contact.component.scss'
})
export class ContactComponent {

    dynamicForm1: DynamicForm = {
        formName: 'Form 1',
        fields: [],
        buttons: [] 
    }

    dynamicForm2: DynamicForm = {
        formName: 'Form 2',
        fields: [],
        buttons: [] 
    }

    constructor() {
        this.dynamicForm1.fields = [
            { name: 'csrf-token1', type: DynamicFormFieldType.HIDDEN, value: 'random-text1' },
            { name: 'name', label: 'Name', type: DynamicFormFieldType.TEXT, required: true },
            { name: 'email', label: 'Email', type: DynamicFormFieldType.EMAIL, required: true },
            { name: 'phone', label: 'Phone', type: DynamicFormFieldType.NUMBER, required: true },
            { name: 'message', label: 'Message', type: DynamicFormFieldType.MULTILINETEXT, required: true }
        ]

        this.dynamicForm1.buttons = [
            { title: 'Ok', click: (event: Event) => this.onOk(event), enabled: true, hidden: false },
            { title: 'Cancel', click: (event: Event) => this.onCancel(event), enabled: true, hidden: false }
        ]

        this.dynamicForm2.fields = [
            { name: 'csrf-token2', type: DynamicFormFieldType.HIDDEN, value: 'random-text2' },
            { name: 'name', label: 'Name', type: DynamicFormFieldType.TEXT, required: true },
            { name: 'email', label: 'Email', type: DynamicFormFieldType.EMAIL, required: true },
            { name: 'phone', label: 'Phone', type: DynamicFormFieldType.NUMBER, required: true },
            { name: 'message', label: 'Message', type: DynamicFormFieldType.MULTILINETEXT, required: true }
        ]

        this.dynamicForm2.buttons = [
            { title: 'Ok', click: (event: Event) => this.onOk(event), enabled: true, hidden: false },
            { title: 'Cancel', click: (event: Event) => this.onCancel(event), enabled: true, hidden: false }
        ]
    }

    async onOk(event: Event) {
        console.log('ok clicked')
        // const item = new Item(0, '', [], 0, true)
        // this.form.instance.update(item)
        // console.log('item is ', item)
        // await this.db.addItem(item)
        // window.history.back()
    }

    onCancel(event: Event) {
        console.log('cancel clicked')
        // window.history.back()
    }

}
