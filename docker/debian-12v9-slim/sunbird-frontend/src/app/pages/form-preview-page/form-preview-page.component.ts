import { Component, OnInit } from '@angular/core';
import { DynamicFormComponent } from "../../components/dynamic-form/dynamic-form.component";
import { ActivatedRoute, Router } from '@angular/router';
import { FormsService } from '../../services/forms.service';
import { DynamicForm, EmptyDynamicForm } from '../../lib/dynamic-form';

@Component({
    selector: 'app-form-preview-page',
    standalone: true,
    imports: [DynamicFormComponent],
    templateUrl: './form-preview-page.component.html',
    styleUrl: './form-preview-page.component.scss'
})
export class FormPreviewPageComponent implements OnInit {

    dynamicForm: DynamicForm = EmptyDynamicForm

    constructor(
        private router: Router,
        private activatedRoute: ActivatedRoute,
        private formService: FormsService
    ) {

    }

    ngOnInit(): void {
        this.activatedRoute.paramMap.subscribe((params) => {
            const key = params.get('key')
            if (key) {
                this.dynamicForm = this.formService.find(key) || EmptyDynamicForm
            }
        })
    }
}
