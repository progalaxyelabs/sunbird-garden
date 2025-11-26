import { Component, ElementRef, ViewChild } from '@angular/core';
import { FormArray, FormBuilder, FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { DynamicForm, DynamicFormField, DynamicFormFieldType, EmptyDynamicForm } from '../../lib/dynamic-form';
import { NgFor } from '@angular/common';
import { FormsService } from '../../services/forms.service';
import { Router } from '@angular/router';
import { DynamicFormComponent } from "../../components/dynamic-form/dynamic-form.component";

export type MyFormFieldDefinition = FormGroup<{
    label: FormControl<string | null>
    type: FormControl<string | null>
    isRequired: FormControl<boolean | null>
}>


@Component({
    selector: 'app-form-editor',
    standalone: true,
    imports: [ReactiveFormsModule, NgFor, DynamicFormComponent],
    templateUrl: './form-editor.component.html',
    styleUrl: './form-editor.component.scss'
})
export class FormEditorComponent {
    @ViewChild('table') tableRef!: ElementRef

    form: FormGroup
    formFields: FormArray<FormGroup>

    previewForm: DynamicForm = EmptyDynamicForm

    // previewFormEntries: DynamicFormField[] = []

    constructor(
        private formBuilder: FormBuilder,
        private formService: FormsService,
        private router: Router
    ) {
        this.form = this.formBuilder.group({
            formName: this.formBuilder.control('', [
                Validators.required,
                Validators.minLength(3)
            ]),
            fields: this.formBuilder.array([])
        })
        this.formFields = this.form.controls['fields'] as FormArray<FormGroup>
        this.form.valueChanges.subscribe((value) => {
            this.updateFormPreview()
        })
    }

    // get fields(): FormArray<FormGroup> {
    //     return this.form.controls['fields'] as FormArray
    // }

    ngOnInit(): void {
        // setTimeout(() => {
            this.addRowAt(0)
        // }, 10)
    }

    addRowAt(i: number): void {
        const formGroup: MyFormFieldDefinition = this.formBuilder.group({
            // name: this.formBuilder.control('', [
            //     Validators.required,
            //     Validators.minLength(3)
            // ]),
            label: this.formBuilder.control('', [
                Validators.required,
                Validators.minLength(3)
            ]),
            type: this.formBuilder.control('', Validators.required),
            isRequired: this.formBuilder.control(false),
        })
        this.formFields.insert(i, formGroup)
    }

    onClick(event: Event, i: number) {
        event.preventDefault()
        const targetType = (event.target as any)?.type
        if (targetType !== 'button') {
            return
        }

        const action = (event.target as HTMLButtonElement).dataset['action']

        switch (action) {
            case 'addabove':
                this.addRowAt(i)
                this.focusNewRow(i)
                break;
            case 'addbelow':
                this.addRowAt(i + 1)
                this.focusNewRow(i + 1)
                break;
            case 'moveup':
                if ((i > 0)) {
                    this.swapFieldDefinitionRows(i - 1, i)
                }
                break;
            case 'movedown':
                if (i < this.formFields.length - 1)
                    this.swapFieldDefinitionRows(i, i + 1)
                break;
            case 'remove':
                this.formFields.removeAt(i)
                break;
        }
        // setTimeout(() => {
        //     this.updateFormPreview()
        // }, 50)
    }

    private focusNewRow(i: number) {
        setTimeout(() => {
            const table = (this.tableRef.nativeElement as HTMLTableElement)
            const selector = `tbody tr:nth-child(${i + 1}) td:first-child input[type="text"]`
            const input = (table.querySelector(selector) as HTMLInputElement)
            input?.focus()
        }, 10)
    }

    private swapFieldDefinitionRows(i: number, j: number): void {
        const ff = this.formFields
        const a = ff.at(i)
        const b = ff.at(j)
        ff.removeAt(i)
        ff.insert(i, b)
        ff.removeAt(j)
        ff.insert(j, a)
    }

    updateFormPreview(): void {
        this.previewForm = this.form.value
        console.log('previewForm is ', this.previewForm)
        // this.previewForm.formName = this.form.controls['formName'].value
        // this.previewForm.fields.length = 0
        // const fieldDefinitions = this.fieldDefinitions.value
        // for (let control of this.fieldDefinitions.controls) {
        //     const field = this.formFieldFromControl(control)
        //     if(!field.name) {
        //         console.warn('FormEditor::updateFormPreview - field name is empty, not adding to json')
        //         continue
        //     }
        //     this.previewForm.fields.push(field)
        // }
    }

    private formFieldFromControl(control: FormGroup<any>): DynamicFormField {
        const formGroup = (control as FormGroup)
        const dynamicFormField = {
            name: (formGroup.controls['label'].value as string).toLocaleLowerCase().replace(/[^a-z0-9]/g, '_'),
            label: formGroup.controls['label'].value,
            type: formGroup.controls['type'].value,
            required: formGroup.controls['isRequired'].value,
        }
        return dynamicFormField
    }

    submit(e: Event) {
        this.updateFormPreview()
    }

    submitReactiveForm(e: Event) {
        // const fields: DynamicFormField[] = []
        // for (let control of this.fieldDefinitions.controls) {
        //     const field = this.formFieldFromControl(control)
        //     if (field.type === DynamicFormFieldType.DROPDOWN) {
        //         field.source = { table: [], labelColumn: '', valueColumn: '' }
        //     }
        //     fields.push(field)
        // }
        // this.formService.add(
        //     {
        //         formName: this.form.controls['formName'].value,
        //         fields: fields,
        //         buttons: []
        //     }
        // )
        this.formService.add(this.previewForm)
        this.router.navigateByUrl('/forms')
    }
}
