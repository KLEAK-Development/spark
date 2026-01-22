@Component(tag: 'contact-form')
class ContactForm {
  static const tag = 'contact-form';

  @Attribute()
  bool isSubmitting = false;

  @Attribute()
  String csrfToken = '';

  Element render() {
    return div([
      form(id: 'contactForm', [
        input(
          type: 'hidden',
          id: 'csrfToken',
          name: 'csrf_token',
          attributes: {'value': csrfToken},
        ),
        button(
          type: 'button',
          id: 'submitBtn',
          className: 'btn-submit',
          attributes: isSubmitting ? {'disabled': 'true'} : {},
          onClick: (_) => _handleSubmit(),
          [isSubmitting ? 'Sending...' : 'Send Message'],
        ),
      ]),
    ]);
  }

  void _handleSubmit() {
    isSubmitting = true;
    scheduleUpdate();
  }

  void anotherHelper() {
    _handleSubmit();
  }
}

// Stub definitions for the test
class Element {}

Element div(List<dynamic> children) => Element();

Element form(List<dynamic> children, {String? id}) => Element();

Element input({
  String? type,
  String? id,
  String? name,
  Map<String, String>? attributes,
}) => Element();

Element button(
  List<dynamic> children, {
  String? type,
  String? id,
  String? className,
  Map<String, String>? attributes,
  Function? onClick,
}) => Element();

void scheduleUpdate() {}
