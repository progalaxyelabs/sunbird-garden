import { AfterContentInit, AfterViewInit, Component, ElementRef, Input, ViewChild } from '@angular/core';
import { DynamicFormField, DynamicFormMultiSelectSource, DynamicFormMultiSelectValue, MultiSelectSourceRecord } from '../../../lib/dynamic-form';
import { CommonModule } from '@angular/common';

@Component({
    selector: 'app-multi-select-control',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './multi-select-control.component.html',
    styleUrl: './multi-select-control.component.scss'
})
export class MultiSelectControlComponent implements AfterContentInit {

    @Input() entry!: DynamicFormField;
    @Input() label?: string
    @ViewChild('checkboxes') checkboxes!: ElementRef
    idPrefix = 'dynamic-' + this.randomString(5)
    isDialogOpen = false
    numSelected = 0
    totalOptions = 0
    source: DynamicFormMultiSelectSource = {
        table: [],
        valueColumn: '',
        labelColumn: ''
    }
    value: DynamicFormMultiSelectValue[] = []
    initialValue: DynamicFormMultiSelectValue[] = []
    checkboxStates: boolean[] = []

    constructor() {

    }

    ngAfterContentInit() {
        if (!this.entry.source) {
            throw ('Invalid Multi Select Control Source for ' + this.label)
        }
        this.source = this.entry.source
        this.value = (this.entry.value as DynamicFormMultiSelectValue[])

        this.totalOptions = this.source.table.length
        this.numSelected = this.value.length

        this.initialValue = JSON.parse(JSON.stringify(this.value))
    }


    onInputClick(event: Event) {
        this.isDialogOpen = true
    }

    onDialogOkClick(event: Event) {
        this.isDialogOpen = false
    }

    onDialogCancelClick(event: Event) {
        this.value.length = 0
        this.value.push(...this.initialValue)
        this.numSelected = this.value.length
        this.isDialogOpen = false
    }

    private randomString(lengthOfCode: number) {
        let possible = 'abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        let text = '';
        for (let i = 0; i < lengthOfCode; i++) {
            text += possible.charAt(Math.floor(Math.random() * possible.length));
        }
        return text;
    }

    isSelected(row: MultiSelectSourceRecord): boolean {
        const index = this.source.valueColumn
        if (!index) {
            return false
        }
        if (this.value.includes(row[index])) {
            return true
        }
        return false
    }

    ngAfterViewInit() {
        console.log('multi select control ngafterviewinit')
    }

    onCheckboxChange(event: Event, row: MultiSelectSourceRecord) {
        const isChecked = (event.target as HTMLInputElement).checked
        if (isChecked) {
            this.includeValue(row[this.source.valueColumn])
        } else {
            this.removeValue(row[this.source.valueColumn])
        }
        this.numSelected = this.value.length
    }

    includeValue(v: string | number) {
        const i = this.value.indexOf(v)
        if (i < 0) {
            this.value.push(v)
        }
    }

    removeValue(v: string | number) {
        const i = this.value.indexOf(v)
        if (i >= 0) {
            this.value.splice(i, 1)
        }
    }
}
