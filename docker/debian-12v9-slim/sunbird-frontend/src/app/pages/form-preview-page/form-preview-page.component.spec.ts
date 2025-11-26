import { ComponentFixture, TestBed } from '@angular/core/testing';

import { FormPreviewPageComponent } from './form-preview-page.component';

describe('FormPreviewPageComponent', () => {
  let component: FormPreviewPageComponent;
  let fixture: ComponentFixture<FormPreviewPageComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [FormPreviewPageComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(FormPreviewPageComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
