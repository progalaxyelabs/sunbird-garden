import { Component, Input, OnInit } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { DynamicForm, DynamicFormButton, DynamicFormField, DynamicFormFieldType } from '../../lib/dynamic-form';
import { CommonModule } from '@angular/common';
import { MultiSelectControlComponent } from './multi-select-control/multi-select-control.component';

@Component({
    selector: 'app-dynamic-form',
    standalone: true,
    imports: [CommonModule, ReactiveFormsModule, MultiSelectControlComponent,],
    templateUrl: './dynamic-form.component.html',
    styleUrl: './dynamic-form.component.scss'
})
export class DynamicFormComponent implements OnInit {

    private _dynamicFormInternal : DynamicForm = { formName: '', fields: [], buttons: [] }

    @Input() 
    set dynamicForm(value: DynamicForm) {
        this._dynamicFormInternal = value

        console.log(`DynamicFormComponent::set_dynamicForm - name is ${this.dynamicForm.formName}, entries are `, this.dynamicForm.fields)
        const controls: any = {}
        for (let field of this._dynamicFormInternal.fields) {
            field.name = field.label?.toLocaleLowerCase().replace(/[^a-z0-9]/g, '_') || ''
            if(!field.name) {
                console.warn('DynamicFormComponent::set_dynamicForm - field name is empty')
                continue
            }
            field.id = 'dynamic-id-' + this.nextFormControlId()
            if (field.value === undefined) {
                field.value = this.defaultValue(field.type)
            }
            if (field.type === DynamicFormFieldType.HIDDEN) {
                field.hidden = true
            }
            console.log('setting dynamic form, field is', field)
            controls[field.name] = new FormControl(field.value)
        }
        this.formGroup = new FormGroup(controls)
    }
    get dynamicForm(): DynamicForm {
        console.log('get_dynamicFormInternal is', this._dynamicFormInternal)
        return this._dynamicFormInternal
    }

    formGroup!: FormGroup

    private static _formControlId = 0

    constructor() {

    }

    ngOnInit() {
        // console.log(`DynamicFormComponent::ngOnInit - name is ${this.dynamicForm.name}, entries are `, this.dynamicForm.entries)
        // const controls: any = {}
        // for (let entry of this.dynamicForm.entries) {
        //     entry.id = 'dynamic-id-' + this.nextFormControlId()
        //     if (entry.value === undefined) {
        //         entry.value = this.defaultValue(entry.type)
        //     }
        //     if (entry.type === DynamicFormFieldType.HIDDEN) {
        //         entry.hidden = true
        //     }
        //     controls[entry.name] = new FormControl(entry.value)
        // }
        // this.formGroup = new FormGroup(controls)
    }

    // protected data: DynamicForm = DynamicForm.dummy()

    onClick(event: Event, source: string) {
        // this.data.buttons.find(b => b.title === source)?.click(event)
    }

    build(entries: DynamicFormField[], buttons: DynamicFormButton[]) {
        // this.data = DynamicForm.build(entries, buttons)
    }

    update(item: any) {
        // console.log('update: entries are', this.data.entries)
        // for(let i = 0; i < this.data.entries.length; i++) {
        //     const e = this.data.entries[i]
        //     if(e.type === DynamicFormFieldType.NUMBER) {
        //         item[e.name] = Number(e.value)
        //     } else {
        //         item[e.name] = e.value
        //     }

        // }
    }

    private nextFormControlId() {
        return ++DynamicFormComponent._formControlId;
    }

    private defaultValue(type: DynamicFormFieldType) {
        switch (type) {
            case DynamicFormFieldType.CHECKBOX:
                return false
            case DynamicFormFieldType.MULTISELECT:
                return []
            default:
                return ''
        }
    }
}
