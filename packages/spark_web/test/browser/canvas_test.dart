@TestOn('browser')
import 'package:spark_web/spark_web.dart' as spark;
import 'package:test/test.dart';

void main() {
  group('Browser Canvas', () {
    test('CanvasRenderingContext2D operations', () {
      final canvas =
          spark.document.createElement('canvas') as spark.HTMLCanvasElement;
      canvas.width = 200;
      canvas.height = 100;
      expect(canvas.width, 200);
      expect(canvas.height, 100);

      final ctx =
          canvas.getContext(spark.CanvasContextType.canvas2d)
              as spark.CanvasRenderingContext2D;
      expect(ctx, isNotNull);
      expect(ctx.canvas.raw, canvas.raw);

      ctx.fillStyle = '#ff0000';
      expect(ctx.fillStyle, '#ff0000');
      ctx.fillRect(0, 0, 10, 10);

      ctx.strokeStyle = '#0000ff';
      expect(ctx.strokeStyle, '#0000ff');
      ctx.strokeRect(10, 10, 10, 10);

      ctx.clearRect(0, 0, 5, 5);

      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.lineTo(100, 100);
      ctx.arc(50, 50, 10, 0, 3.14);
      ctx.closePath();
      ctx.stroke();

      ctx.font = '10px Arial';
      expect(ctx.font, contains('Arial'));
      ctx.fillText('hello', 0, 0);

      final data = ctx.getImageData(0, 0, 10, 10);
      expect(data.width, 10);
      expect(data.height, 10);
      expect(data.data.length, 400); // 10*10*4

      expect(ctx.measureText('hello').width, isNonNegative);

      ctx.setLineDash([5, 5]);
      expect(ctx.getLineDash(), equals([5, 5]));
    });
  });
}
