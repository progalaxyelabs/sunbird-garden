import { NgFor, NgIf } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { FormNames, FormsService } from '../../services/forms.service';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';

@Component({
    selector: 'app-forms',
    standalone: true,
    imports: [NgIf, NgFor, RouterLink, RouterLinkActive, RouterOutlet],
    templateUrl: './forms.component.html',
    styleUrl: './forms.component.scss'
})
export class FormsComponent implements OnInit {

    constructor(
        private forms: FormsService
    ) {

    }
    
    names: FormNames = []

    ngOnInit() {
        this.names = this.forms.names()
    }

}
