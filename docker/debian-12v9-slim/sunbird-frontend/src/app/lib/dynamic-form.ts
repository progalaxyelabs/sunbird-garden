export enum DynamicFormFieldType {
    NUMBER = 'number',
    TEXT = 'text',
    EMAIL = 'email',
    SECRET = 'secret',
    MULTILINETEXT = 'multilinetext',
    CHECKBOX = 'checkbox',
    HIDDEN = 'hidden',
    DROPDOWN = 'dropdown',
    MULTISELECT = 'multiselect',
    DATE = 'date'
}

// export function getDynamicFormFieldType(str: string | number | boolean | undefined): DynamicFormFieldType {
//     switch(str) {
//         case 'number':
//             return DynamicFormFieldType.NUMBER
//         case 'text':
//             return DynamicFormFieldType.TEXT
//         case 'email':
//             return DynamicFormFieldType.EMAIL
//         case 'secret':
//             return DynamicFormFieldType.SECRET
//         case 'multilinetext':
//             return DynamicFormFieldType.MULTILINETEXT
//         case 'checkbox':
//             return DynamicFormFieldType.CHECKBOX
//         case 'hidden':
//             return DynamicFormFieldType.HIDDEN
//         case 'dropdown':
//             return DynamicFormFieldType.DROPDOWN
//         case 'multiselect':
//             return DynamicFormFieldType.MULTISELECT
//         case 'date':
//             return DynamicFormFieldType.DATE
//         default:
//             return DynamicFormFieldType.TEXT
//     }        

// }

export type MultiSelectSourceRecord = {
    [name: string]: any
}

export type DynamicFormMultiSelectValue = string | number

export interface DynamicFormMultiSelectSource {
    table: MultiSelectSourceRecord[]
    valueColumn: string
    labelColumn: string
}

export interface DynamicFormField {
    id?: string
    name: string
    label?: string
    type: DynamicFormFieldType
    hidden?: boolean
    value?: string | number | boolean | DynamicFormMultiSelectValue[]
    source?: DynamicFormMultiSelectSource
    required?: boolean
}


export class DynamicFormButton {
    title = ''
    click = (event: Event) => { }
    enabled = true
    hidden = false
}

export type DynamicForm = {    
    formName: string
    fields: DynamicFormField[]
    buttons: DynamicFormButton[]
}

export const EmptyDynamicForm = { formName: '', fields: [], buttons: [] }


///////////////////////////////////////////////////////////////////////////////////////

// export class DynamicForm {
//     private static _id = 0
//     private constructor(
//         public entries: DynamicFormEntry[] = [],
//         public buttons: DynamicFormButton[] = []
//     ) {
//         for (let entry of this.entries) {
//             entry.id = 'dynamic-id-' + this.nextId()
//             if (entry.value === undefined) {
//                 entry.value = this.defaultValue(entry.type)
//             }
//         }
//     }

//     static build(
//         entries: DynamicFormEntry[],
//         buttons: DynamicFormButton[]
//     ): DynamicForm {
//         return new DynamicForm(entries, buttons)
//     }

//     static dummy(): DynamicForm {
//         return new DynamicForm([], [])
//     }

//     private nextId() {
//         return ++DynamicForm._id;
//     }

//     private defaultValue(kind: DynamicFormFieldType) {
//         switch (kind) {
//             case DynamicFormFieldType.TEXT:
//                 return ''
//             case DynamicFormFieldType.NUMBER:
//                 return ''
//             case DynamicFormFieldType.HIDDEN:
//                 return ''
//             case DynamicFormFieldType.CHECKBOX:
//                 return false
//             case DynamicFormFieldType.MULTISELECT:
//                 return []
//             default:
//                 return ''
//         }
//     }

// }

/////////////////////////////////////////////////////////////////////

// export const DynamicFormFieldType = {
//     NUMBER: 'number',
//     TEXT: 'text',
//     EMAIL: 'email',
//     SECRET: 'secret',
//     LONGTEXT: 'longtext',
//     CHECKBOX: 'checkbox',
//     HIDDEN: 'hidden',
//     SELECT: 'select',
//     MULTISELECT: 'multiselect',
//     DATE: 'date'
// }

// export class DynamicFormControlBase<T> {
//     value: T | undefined;
//     key: string;
//     label: string;
//     required: boolean;
//     order: number;
//     controlType: string;
//     type: string;
//     options: { key: string; value: string }[];
//     constructor(
//         options: {
//             value?: T;
//             key?: string;
//             label?: string;
//             required?: boolean;
//             order?: number;
//             controlType?: string;
//             type?: string;
//             options?: { key: string; value: string }[];
//         } = {},
//     ) {
//         this.value = options.value;
//         this.key = options.key || '';
//         this.label = options.label || '';
//         this.required = !!options.required;
//         this.order = options.order === undefined ? 1 : options.order;
//         this.controlType = options.controlType || '';
//         this.type = options.type || '';
//         this.options = options.options || [];
//     }
// }

// export class TextboxQuestion extends QuestionBase<string> {  override controlType = 'textbox';}

// export function toFormGroup(fields: DynamicFormControlBase<string>[]) {
//     const group: any = {};
//     fields.forEach((field) => {
//         group[field.key] = field.required ?
//             new FormControl(field.value || '', Validators.required)
//             : new FormControl(field.value || '');
//     });
//     return new FormGroup(group);
// }